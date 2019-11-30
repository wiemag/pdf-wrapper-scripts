#!/bin/bash
# by wm (dif)
# Repair a corrupted PDF
# Some tips:  http://milan.kupcevic.net/ghostscript-ps-pdf/
#
USAGE='\nThe script repairs corrupted PDFs.\n'
USAGE=${USAGE}"\nUsage:\n\t${0##*/} [-m METHOD] [-i] INPUT.pdf | -h | --help\n"
USAGE=${USAGE}'\n-i : an in-place repair (modifies the input file)\n'
USAGE=${USAGE}'\nMethods  (default = 1)'
USAGE=${USAGE}'\n1  : pdftops --> ps2pdf --> INPUT_repaired.pdf'
USAGE=${USAGE}'\n2  : pdftops --> gs (print) --> INPUT_repaired.pdf'
USAGE=${USAGE}'\n3  : pdftocairo --> gs (print) --> INPUT_repaired.pdf\n'
USAGE=${USAGE}'\n30 : pdftocairo --> gs (print/screen 72 dpi)'
USAGE=${USAGE}'\n31 : pdftocairo --> gs (print/eboot 150 dpi)'
USAGE=${USAGE}'\n32 : pdftocairo --> gs (print/printer 300 dpi) (like option 3)'
USAGE=${USAGE}'\n33 : pdftocairo --> gs (print/prepress 300 dpi, colour preserving)'
USAGE=${USAGE}'\n34 : pdftocairo --> gs (print/default) (like prepress)\n'
VERSION=0.4
METHOD=1
INPLACE=0
[[ $1 = '--help' ]] && { echo -e $USAGE; exit;}
# Parse dash-options
while getopts m:?hvid OPT; do
    case "$OPT" in
        h|\?) echo -e $USAGE; exit;;
        v) echo ${0##*/}, version $VERSION; exit;;
        m) METHOD=$OPTARG;;
        i|d) INPLACE=1;;
    esac
done
shift $(expr $OPTIND - 1)

[[ $# -eq 0 ]] && { echo -e "\nNo files to repair.\nUse --help or -h."; exit;}

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for INPUT in $@; do
	if [[ $(file -b "$INPUT" |cut -d\  -f1) == 'PDF' ]]; then
		case $METHOD in
		'1') pdftops "$INPUT" "/tmp/${INPUT%.pdf}.ps";
		ps2pdf "/tmp/${INPUT%.pdf}.ps" "${INPUT%.pdf}_repaired_${METHOD}.pdf";;

		'2') pdftops "$INPUT" "/tmp/${INPUT%.pdf}.ps";
		gs -o "${INPUT%.pdf}_repaired_${METHOD}.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/default "/tmp/${INPUT%.pdf}.ps";;

		'3'|'32') pdftocairo -pdf "$INPUT" "/tmp/${INPUT}";
		# Tutaj drugi krok jest zbędy, ale może znacząco zmniejszyć wielkość zbioru.
		gs -o "${INPUT%.pdf}_repaired_${METHOD}.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/printer "/tmp/${INPUT}";;
		'30') pdftocairo -pdf "$INPUT" "/tmp/${INPUT}";
		gs -o "${INPUT%.pdf}_repaired_${METHOD}.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/screen "/tmp/${INPUT}";;
		'31') pdftocairo -pdf "$INPUT" "/tmp/${INPUT}";
		gs -o "${INPUT%.pdf}_repaired_${METHOD}.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook "/tmp/${INPUT}";;
		'33') pdftocairo -pdf "$INPUT" "/tmp/${INPUT}";
		gs -o "${INPUT%.pdf}_repaired_${METHOD}.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress "/tmp/${INPUT}";;
		'34') pdftocairo -pdf "$INPUT" "/tmp/${INPUT}";
		gs -o "${INPUT%.pdf}_repaired_${METHOD}.pdf" -sDEVICE=pdfwrite -dPDFSETTINGS=/default "/tmp/${INPUT}";;
		esac
		rm "/tmp/${INPUT%.pdf}".{pdf,ps} 2>/dev/null;
		# remove mata data if qpdf is installed
		hash qpdf 2>/dev/null && {
			qpdf -empty -pages "${INPUT%.pdf}_repaired_${METHOD}.pdf" 1-z -- /tmp/${0##*/}-temp;
			mv /tmp/${0##*/}-temp "${INPUT%.pdf}_repaired_${METHOD}.pdf";
		}
		[[ $INPLACE -eq 0 ]] && echo "[OK] ${INPUT%.pdf}_repaired_${METHOD}.pdf" || mv "${INPUT%.pdf}_repaired_${METHOD}.pdf" "${INPUT}"
	else
		[[ -f "$INPUT" ]] && echo "[!] '$INPUT' is not a PDF." ||
			echo "[!] '$INPUT' does not exist."
	fi
done
IFS=$SAVEIFS

hash qpdf 2>/dev/null || { qpdf -empty -pages "$INPUT" 1-z -- "$OUTPUT"
}
