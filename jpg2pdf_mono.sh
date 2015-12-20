#!/bin/bash
VERSION="1.0" 		# 2015-12-20
function usage () {
	echo -e "\nUsage:\n\t\e[1m${0##*/} [-t Threshold] [-c CompressionType] filename\e[0m\n"
	echo -e "The 'Threshold' [0..100%] whitens/backens pixels."
	echo -e "\tThe closer to 0%, the whiter the image."
	echo -e "The 'CompressionType' as defined for imagemagick's convert:"
	echo -e "\tGroup4 (default), Fax, JPEG, JPEG2000, Lossless"
	echo -e "\tLZW, RLE, ZIP, BZip, or just None."
	echo -e "Command \n\t\e[1mconvert -list compress\e[0m"
	echo -e "will show a full list of compression types.\n"
}
CMPR="-compress Group4"		# Compression type
THRE="" 					# Threshold
while getopts "t:c:hv" flag
do
    case "$flag" in
		h) usage; exit;;
		v) echo -e "${0##*/} version ${VERSION}" && exit;;
		t) THRE="-threshold $OPTARG";;
		c) CMPR="-compress $OPTARG";;
	esac
done
# Remove the options parsed above.
shift `expr $OPTIND - 1`
(( $# )) || { usage; exit;}

while [[ $# -gt 0 ]]; do
	f="$1"
	if [[ -e "$f" ]]; then
		echo convert $f $THRE $CMPR -enhance -monochrome "${f%.*}.pdf"
		convert "$f" $THRE $CMPR -enhance -monochrome "${f%.*}.pdf"
	else
		[[ "$f" =~ '*' ]] && echo Files $f do not exist. || echo File $f does not exist.
	fi
	shift
done
