#!/bin/bash
# Convert a PDF file into an A4 format.
# by Wiesław Magusiak, 2015-10-10
VERSION=1.0
function usemsg (){
	echo -e "\nUsage:\n\tpdf-a4.sh [--nocheck] file.pdf"
	echo -e "\n--nocheck = start converting to A4 without checking the file."
}

function depcheck (){
	hash $1 2>/dev/null || {
	echo -e "\nMissing dependency.\nCommand \e[1m${1}\e[0m needed."
	[[ -n $2 ]] && echo -e "Install the \e[1m${2}\e[0m package."
	return 1
	}
}

depcheck pdfinfo poppler || exit
depcheck awk gawk || exit

[[ $# = 0 ]] || [[ $1 = --help || $1 = -h ]] && { usemsg; exit;}
NCK=0 		# Check the file before converting?
FILE="$1"
[[ "$FILE" = '--nocheck' ]] && { NCK=1; FILE="$2";} || [[ $2 = --nocheck ]] && NCK=1

[[ -f "$FILE" ]] || { echo File $FILE does not exist; exit;}

if ! [[ $2 = '--nocheck' ]]; then
	depcheck qpdf qpdf && {
		qpdf --check "$FILE" 1>/dev/null
		[[ $? -eq 0 ]] || echo '----------------------'
	}
	x=$(pdfinfo "$FILE" |awk '/Page size/ {print $3" "$5}')
	y=${x#* }; x=${x% *}
	a4x=595; a4y=842
	scale=$(echo $x $a4x | awk '{print $1/$2}')
	[[ $scale = 1 ]] && {
		echo -e "\nFile $FILE is already A4."
		exit
	}
fi

PDFVer=$(pdfinfo "$FILE" |awk '/PDF version/ {print $3}')
OUTPUT=${FILE%.pdf}
OUTPUT=${OUTPUT%.PDF}_a4.pdf
gs  -o "$OUTPUT" -sDEVICE=pdfwrite -sPAPERSIZE=a4 \
	-dFIXEDMEDIA -dPDFFitPage -dCompatibilityLevel=$PDFVer "$FILE"
