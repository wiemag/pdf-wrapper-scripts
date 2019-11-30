#!/bin/bash -
# Removes meta data form PDFs

# Check dependencies
hash qpdf 2>/dev/null || {
	echo -e "\n\e[31;1mMissing dependency:\e[0m qpdf\n"
	exit 1
}

VERSION=2.01
USAGE="\nThe script removes all meta data, including the table of contents.
\n\nUsage:\n
\t${0##*/} [-o OUTPUT] [-c] input1 [input2 [input3 [...]]]\n
\n-o\tIf used, only the first input file is processed.\n
\tIf not used, _no-meta.pdf suffix added to input file names.
\n-c|-i\tClean/Inplace. Rename OUTPUT back into INPUT orginal file name.\n"
OUTMODE=0

# Parse dash-options
while getopts o:ci?hv OPT; do
    case "$OPT" in
        h|\?) echo -e $USAGE; exit;;
        v) echo ${0##*/}, version $VERSION; exit;;
        o) OUTPUT=$OPTARG; OUTMODE=1;;
        c|i) CLEAN=1;;
    esac
done
shift $(expr $OPTIND - 1)

[[ $# -lt 1 ]]  && { echo -e $USAGE; exit;}

for INPUT in "$@"; do
	if [[ -f "$INPUT" ]]; then
		if [[ $(file -b "$INPUT" |cut -d\  -f1) == 'PDF' ]]; then
			[[ $OUTMODE -eq 0 ]] && OUTPUT="${INPUT%.pdf}_no-meta.pdf"
			qpdf -empty -pages "$INPUT" 1-z -- "$OUTPUT"
			[[ $CLEAN -eq 1 ]] && mv "$OUTPUT" "$INPUT"
		else
			echo "[!] '$INPUT' is not a PDF."
		fi
	else
		echo -e "File '$INPUT' does not exist."
	fi
	[[ $OUTMODE -eq 1 ]] && exit || :
done
