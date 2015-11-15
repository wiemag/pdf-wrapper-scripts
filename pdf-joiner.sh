#!/bin/bash
# A simple qpdf-based pdf-files joining script.
# by W.Magusiak (dif/wiemag) 2015-11-14
#

function usg_msg() {
echo -e "\nUsage:\n\techo ${0##*/} space-separated-PDF-files output.pdf\n"
echo Merges the PDF files into an output.pdf,
echo adding all the pages of all the files.
}

[[ $# -eq 0 ]] || [[ $1 == '-h' ]] || [[ $1 == '--help' ]] && { usg_msg; exit;}

FLINE="$@"
OUTPUT="${FLINE##* }" 	# The last argument is the output file name.
Q='n'
if [[ -f "$OUTPUT" ]]; then
	echo -e "\n$OUTPUT already exists."
	read -t5 -n1 -p 'Overwrite it?  (y/N) ' Q
	[[ ${Q,,} != 'y' ]] && { echo -e "\nExiting..."; exit;}
fi
FLINE=${FLINE% *}" "
for f in $FLINE; do
	qpdf --check $f > /dev/null
	[[ $? -gt 0 ]] && { echo Wrong file:  $f;
		echo Check it with \'qpdf --check $f\';
		echo or with "     "\'file $f\';
		exit;}
done
FLINE=${FLINE// / 1-z }

qpdf -empty --pages $FLINE -- $OUTPUT
