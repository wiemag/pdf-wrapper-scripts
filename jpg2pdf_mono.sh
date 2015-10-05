#!/bin/bash
VERSION="0.2" 		# 2013-10-01, Correction of $path 
function usage () {
	echo -e "\nUsage:\n\t\e[1m${0##*/} -c CompressionType filename\e[0m\n"
	echo -e "The 'CompressionType' as defined for imagemagick's convert:"
	echo -e "\tGroup4 (default), Fax, JPEG, JPEG2000, Lossless"
	echo -e "\tLZW, RLE, ZIP, BZip, or just None."
	echo -e "Command \n\t\e[1mconvert -list compress\e[0m"
	echo -e "will show a full list of compression types.\n"
}
CMPR="Group4"		# Compression type
while getopts "c:hv" flag
do
    case "$flag" in
		h) usage; exit;;
		v) echo -e "${0##*/} version ${VERSION}" && exit;;
		c) CMPR="$OPTARG";;
	esac
done
# Remove the options parsed above.
shift `expr $OPTIND - 1`
(( $# )) || { usage; echo -e "\e[31;1mMissing file name.\e[0m" ; exit;}

path=${1%/*}
[[ "$path" = "$1" ]] && path="."
f=${1##*/}
f=${f%.*}
if [[ -e "$1" ]]; then
	convert "$1" -compress "$CMPR" -monochrome -enhance "/tmp/${f}.tif"
	convert "/tmp/${f}.tif" "${path}/${f}.pdf"
	rm "/tmp/${f}.tif"
else
	usage
	echo File $1 does not exist
fi
