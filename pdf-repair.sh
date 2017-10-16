#!/bin/bash
# by wm (dif)
# Repair a corrupted PDF
#
USAGE='\nThe script repairs corrupted PDFs.\n'
USAGE=${USAGE}"\nUsage:\n\t${0##*/} -m METHOD INPUT.pdf\n"
USAGE=${USAGE}'\nMethods  (default = 1)'
USAGE=${USAGE}'\n1: pdftops --> ps2pdf --> INPUT_repaired.pdf'
USAGE=${USAGE}'\n2: pdftops --> gs (print) --> INPUT_repaired.pdf'
USAGE=${USAGE}'\n3: pdftocairo --> gs (print) --> INPUT_repaired.pdf'
VERSION=0.2
METHOD=1
# Parse dash-options
while getopts m:?hv OPT; do
    case "$OPT" in
        h|\?) echo -e $USAGE; exit;;
        v) echo ${0##*/}, version $VERSION; exit;;
        m) METHOD=$OPTARG;;
    esac
done
shift $(expr $OPTIND - 1)

[[ $# -eq 0 ]] && { echo -e "\nNo files to repair."; exit;}

for INPUT in $@; do
	# Input file (the file to be stamped)
	[[ $# -lt 1 ]]  && { echo -e $USAGE; exit;}
	if [[ $(file -b "$INPUT" |cut -d\  -f1) == 'PDF' ]]; then
		case $METHOD in
		'1') pdftops "$INPUT" "/tmp/${INPUT%.pdf}.ps";
		ps2pdf "/tmp/${INPUT%.pdf}.ps" "${INPUT%.pdf}_repaired.pdf";
		rm "/tmp/${INPUT%.pdf}.ps";;

		'2') pdftops "$INPUT" "/tmp/${INPUT%.pdf}.ps";
		gs -o "${INPUT%.pdf}_repaired.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/default "/tmp/${INPUT%.pdf}.ps";
		rm "/tmp/${INPUT%.pdf}.ps";;

		'3') pdftocairo -pdf "$INPUT" "/tmp/${INPUT}";
		# Tutaj drugi krok jest zbędy, ale może znacząco zmniejszyć wielkość zbioru.
		gs -o "${INPUT%.pdf}_repaired.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/default "/tmp/${INPUT}";
		rm "/tmp/${INPUT}";;
		esac
		echo "[OK] ${INPUT%.pdf}_repaired.pdf"
	else
		[[ -f "$INPUT" ]] && echo "[!] '$INPUT' is not a PDF." ||
			echo "[!] '$INPUT' does not exist."
	fi
done
