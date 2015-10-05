#!/bin/bash
# The pdftk package required!
#
VERSION="0.2" 		# 2015-09-04
function usage () {
echo -ne "\nUsage:\n\n\e[1m  ${0##*/} [-p page_range] [-r rot_direction]"
echo -e " FileName[.pdf] | -h | -V\e[0m\n"
echo A simplified and very limited version of \'pdftk\'
echo Rotates page_range pages acc. to rot_direction \(right, left, down\).
echo -e "Produces an output file named:  \e[33;1mFileName_rot.pdf\e[0m\n"
echo -e "\e[1m-p\e[0m page_range    :  Defaults to 1-end i.e. all the pages."
echo -e "                    Allowed formats:"
echo -e "                    - page_number, e.g 7"
echo -e "                    - page_range, e.g 3-6 or 4-end"
echo -e "                    Separate ranges not allowed here."
echo -e "\e[1m-r\e[0m rot_direction :  Defaults to right (east)."
echo -e "\e[1m-h\e[0m               :  Prints this help message."
echo -e "\e[1m-V\e[0m               :  Prints the script version number."
}

hash pdftk 2>/dev/null || {
	echo -e "\n\e[31;1mMissing dependency:\e[0m package for pdftk\n"
	exit
}

PAGES='1-end'
ROTDIR='right'
while getopts "p:r:hV" flag
do
    case "$flag" in
		p) PAGES="$OPTARG";;
		r) ROTDIR="$OPTARG";;
		h) usage; exit;;
		V) echo -e "${0##*/} version ${VERSION}" && exit;;
	esac
done
# Remove the options parsed above.
shift `expr $OPTIND - 1`
(( $# )) || { usage; echo -e "\n\e[31;1mMissing file name.\e[0m" ; exit;}

f=${1}
[[ -f "$f" ]] || f=${f}.pdf 	# As the pdf extension is optional.

if [[ -f "$f" ]]; then
	nf=$f
	ext=${f##*.}; [[ ${ext,,} = 'pdf' ]] && nf=${nf%.*} #${ext,,} lowercase
	nf=${nf}_rot.pdf
	bn=${f##*/}
	case $LANG in
		pl*) echo Wykonuję polecenie;;
		*) echo Processing...;;
	esac
	echo pdftk $f rotate "${PAGES}${ROTDIR}" output "$nf"
	pdftk "$f" rotate ${PAGES}${ROTDIR} output "$nf"
else
	usage
	echo -e "\n\e[31;1mFile $f does not exist.\e[0m"
fi
