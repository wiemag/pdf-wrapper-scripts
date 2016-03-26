#!/bin/bash

# Dependencies:
# pdfcrop  -  texlive owned
# pdfinfo  -  poppler
# file     -  file
# awk      -  gawk
# xargs    -  findutils
# e.g. pdfcrop --margins 'left top righ bottom' input.pdf output.pdf
# Note:  The margins parameter is quoted with apostrophies and space-separated.
VERSION=0.1
MARGINS=''
SIZE=0
while getopts :m:sv FLAG; do
	case $FLAG in
		m) MARGINS="$OPTARG";;
		s) SIZE=1;;
		v) echo -e "\n${0##*/} ver. $VERSION"; exit;;
	esac
done
shift $((OPTIND-1))
INPUT=$1

( [[ $SIZE -eq 0 ]] && [[ -z "$MARGINS" ]] ) || [[ -z $INPUT ]] && {
cat << HLP

${0##*/} -m 'left top right down' input.pdf [output.pdf]
or
${0##*/} -s input.pdf

-m margins
	Note! Use negative values to actually trim/crop the page.
	Positive margin values expand the page.
	This is a pdfcrop wrapper.
-s
	Just print the size of the pdf page.
	(Orientation taken into account.)

HLP
exit 1
}

[[ -f "$INPUT" ]] || { echo -e "\n$INPUT does not exist!"; exit 2;}
[[ $(file "$INPUT" | grep "PDF document") ]] || {
	echo -e "\n$INPUT is not a PDF file."
	exit 3
}

ROT=$(pdfinfo "$INPUT" |awk '/rot/ {print $3}') # Rotated? How much?
[[ $ROT -eq 0 ]] || [[ $ROT -eq 180 ]] && {
pdfinfo "$INPUT" |awk '/pts/ {print "\nPage size: "$3" x "$5" pts"}'
} || {
pdfinfo "$INPUT" |awk '/pts/ {print "\nPage size: "$5" x "$3" pts"}'
}

[[ $SIZE -eq 0 ]] && {
	echo --margins "'$MARGINS'" $(echo $INPUT | sed 's/ /\\ /g') $(echo $2 | sed 's/ /\\ /g') | xargs pdfcrop
}
