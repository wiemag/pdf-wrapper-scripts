#!/bin/bash
# by wm (dif)

# Dependecies:
#  od belongs to coreutils
#  iconv belongs to iconv
#  qpdf required for removing old bookmarks (and all meta data)
hash iconv 2>/dev/null || { echo -e "Missing dependency.\nInstall the 'iconv' package."; exit 100;}
hash qpdf 2>/dev/null || { echo -e "Missing dependency.\nInstall the 'qpdf' package."; exit 100;}

function helpmsg() {
	echo -e "\nUsage:\n\t${0##*/} -t TABLE-OF-CONTENTS INPUT.pdf\n";
	echo It removes bookmarks and meta data from PDF_INFILE before adding new ones.;
}

# Check in input string includes a non-ascii character
function nonascii() { LANG=C grep -qo '.*[^ -~]\+.*' <<<$1; }
# $?: 0 - non-ascii found; 1 - non-ascii not found

function toc-2-u16() {
	local LINE REPLACE TEXT
	while IFS= read -r LINE; do
		REPLACE=''
		TEXT="${LINE#*Title (}"
		TEXT="${TEXT%)*}"
		[[ -n "$TEXT" ]] && nonascii "$TEXT" && {
			REPLACE="$(echo -n "$TEXT" | iconv -f utf-8 -t utf-16|od -An -tx2)"
			REPLACE='<'${REPLACE// /}'>'
			LINE="${LINE/\($TEXT\)/$REPLACE}"
		}
		echo $LINE
	done < "$TOC"
}

[[ $# -lt 2 ]] || [[ "$1" = '--help' ]] && { helpmsg; exit;}

[[ "$1" = '-t' ]] && shift
TOC="$1"
[[ -f "$TOC" ]] || { echo $TOC does not exist.; exit 2;}
[[ $# -ne 2 ]] && { helpmsg; exit;}
INFILE="$2"
[[ -f "$INFILE" ]] || { echo $INFILE does not exist.; exit 3;}
[[ $(file -b "$INFILE" | cut -d\  -f1) != "PDF" ]] &&
	{ echo $INFILE is not a PDF file!; exit 4;}

# Remove all meta data from the input PDF
qpdf -empty --pages "$INFILE" 1-z -- "/tmp/${INFILE}"

gs -q -sDEVICE=pdfwrite \
	-o ${INFILE%.pdf}_bkms.pdf \
    "/tmp/$INFILE" <(toc-2-u16 "$TOC")
#	-dPDFSETTINGS=/printer \

rm "/tmp/${INFILE}"

# See, extremely useful!:
# https://superuser.com/questions/360216/use-ghostscript-but-tell-it-to-not-reprocess-images
# The additional options tell GS not to re-process the images.
#

# ENTRY='[/Title SS /Page /View /Color [] /F INT [/XYZ null null null] /OUT pdfmark'
#
# /Title (required): The bookmark’s text.
# The encoding and character set used is either PDFDocEncoding (as described in the PDF Reference) or Unicode.
# If Unicode, the string must begin with <FEFF>.
# For example, the Unicode string for (ABC) is <FEFF004100420043>.
# Title has a maximum length of 255 PDFDocEncoding characters or 126 Unicode values.
#
# /Color (optional): Array of three numbers (red, green, and blue),
# each of which must be between 0 and 1, inclusive, specifying a color in the DeviceRGB color space.
# (See the PDF Reference for a description of this color space.)
# /F (optional):  An integer defining the style of the bookmark:
# ● 0 — Plain (the default), ● 1 — Italic, ● 2 — Bold, ● 3 — Bold and Italic.
#

