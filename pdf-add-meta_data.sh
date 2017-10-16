#!/bin/bash
# by wm (dif)

function nonascii() { LANG=C grep -qo '.*[^ -~]\+.*' <<<$1; }
# $?: 0 - non-ascii found; 1 - non-ascii not found

function conv-2-u16_w_brackets() {
	local var
	var="$1"
	nonascii "$var" && {
    	var="<$(echo -n "$var" | iconv -f utf-8 -t utf-16|od -An -tx2)>"
    	var="${var// /}"
    } || var="(${var})"
	echo $var
}

USAGE="\nUsage:\n\t ${0##*/} -t TITLE -a AUTHOR -s SUBJECT [-c] [-o OUTPUT] INPUT.pdf\n
The script puts meta data in the INPUT.pdf.
It is a simple gs wrapper. Use gs or pdftk in more complicated cases.\n
INPUT_.pdf is created unless '-c' flag or '-o' flag is used.
All the options are optional.
-c sort of in-place action (renames INPUT_.pdf back to INPUT.pdf)
-o creates an individual, new-name OUTPUT file instead of INPUT_.pdf\n"
VERSION=0.99
TITLE='()'
AUTHOR='()'
SUBJECT='()'
KEYWORDS='()'

TASK=0 # Has -t, -a, -s or -k been used?

# Parse dash-options
while getopts t:a:s:k:o:c?hv OPT; do
    case "$OPT" in
        h|\?) echo -e "$USAGE"; exit;;
        v) echo ${0##*/}, version $VERSION; exit;;
        o) OUTPUT=$OPTARG; OUTMODE=1;;
        c) CLEAN=1;;
        t) TASK=1; TITLE="$(conv-2-u16_w_brackets "$OPTARG")";;
        a) TASK=1; AUTHOR="$(conv-2-u16_w_brackets "$OPTARG")";;
        s) TASK=1; SUBJECT="$(conv-2-u16_w_brackets "$OPTARG")";;
        k) TASK=1; KEYWORDS="${OPTARG//,/, }"; KEYWORDS="${KEYWORDS//  / }";
           KEYWORDS="$(conv-2-u16_w_brackets "$KEYWORDS")";;
    esac
done
shift $(expr $OPTIND - 1)

[[ $# -eq 0 ]] || [[ $TASK -eq 0 ]] && { echo -e "$USAGE"; exit;}

INPUT="$1"
[[ -f "$INPUT" ]] || { echo $INPUT does not exist.; exit 1;}
[[ $OUTMODE -eq 0 ]] && OUTPUT="${INPUT%.pdf}_.pdf"

# META: round brackets or sharp brackets are already in the varables
META="[ /Title $TITLE /Author $AUTHOR /Subject $SUBJECT /Keywords $KEYWORDS /DOCINFO pdfmark"
gs -dSAFER -sDEVICE=pdfwrite -o "$OUTPUT" "$INPUT" <(echo $META)

# It's safer to rename than do the actual in-place PDF printing in case INPUT is 'semi' corrupted
[[ $OUTMODE -eq 0 ]] && [[ $CLEAN -eq 1 ]] && mv "${INPUT%.pdf}_.pdf" "$INPUT" || :
