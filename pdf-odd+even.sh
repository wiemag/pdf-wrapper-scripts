#!/bin/bash
# by Wiesław Magusiak, 2015-09-29
# Join odd and even pages into one PDF file.
# Number off odd pages has to be equal to or larger by one than
# the number of even pages.
#

hash qpdf 2>/dev/null || {
    echo -e "\n\e[31;1mMissing dependency:\e[0m qpdf\n"
	exit 10
}

VER='1.1'
function abs() { echo ${1/-/};}
function usage_msg() {
echo -e "\nUsage:\n\t${0##*/} [-1] [-2] input1.pdf input2.pdf output.pdf\n"
cat <<INFO
The input files hold odd and even pages of the output.pdf
 -1 uses the reverse order of the page numbers in file 1
 -2 reverses the page order of file 2
INFO
}

[[ $# -eq 0 ]] || [[ "$1" = '-h' || "$1" = '--help' ]] && { usage_msg; exit;}
REV1=0; REV2=0
PRINT=0 # If 1, prints the commad before running it.
while getopts :12pv OPT; do
    case "$OPT" in
    	1) REV1=1;; # Reverse PDF file1
    	2) REV2=1;; # Reverse PDF file2
    	p) PRINT=1;;
        v) echo -e "\n${0##*/} v. $VER"; exit;;
    esac
done

shift $(expr $OPTIND - 1)
IN1="$1"
[[ -z "$IN1" ]] && { usage_msg; exit;}
[[ -f "$IN1" ]] && IN2="$2" || { echo File $IN1 does not exist.; exit 1;}
qpdf --check "$IN1" 1>/dev/null 2>/dev/null || \
	{ echo -e "\n${IN1}: Wrong PDF file.";exit 2;}
[[ -z "$IN2" ]] && { usage_msg; exit;}
[[ -f "$IN2" ]] && OUT="$3" || { echo File $IN2 does not exist.; exit 3;}
qpdf --check "$IN2" 1>/dev/null 2>/dev/null || \
	{ echo -e "\n${IN2}: Wrong PDF file.";exit 4;}

PGS1=$(qpdf --show-npages "$IN1")
PGS2=$(qpdf --show-npages "$IN2")
#if [[ $(abs $((PGS1 - PGS2))) -gt 1 ]]; then
if [ $((PGS1 - PGS2)) -gt 1 -o $((PGS1 - PGS2)) -lt 0 ]; then
	echo -e "\nNumber of odd pages does not suit the number of even pages."
	echo '  File_1_pages = '$PGS1
	echo '  File_2_pages = '$PGS2
	echo Constraint:
	echo '  0 =< File_1_pages - File_2_pages =< 1'
	exit 5
fi

[[ -z "$OUT" ]] && { echo -e "\nMissing output file.";usage_msg; exit;}
if [[ -f "$OUT" ]]; then
	echo -e "\nFile $OUT exists."
	read -p 'Overwrite? (y/N) ' -n1 -t10 Q
	[[ ${Q,,} != 'y' ]] && exit || echo
fi

CMD="qpdf"
s=' -empty --pages'
for ((i=0; i<$PGS1; i++)); do
	((REV1)) && j=$((PGS1-i)) || j=$((i+1))
	((REV2)) && k=$((PGS2-i)) || k=$((i+1))
	s=${s}" \"$IN1\" $j"
	(( i<PGS2 )) && s=${s}" \"$IN2\" $k"
done
s=${s}" -- \"$OUT\""
(( $PRINT )) && echo ${CMD}$s

echo $s |xargs qpdf
