#!/bin/bash
VERSION="0.4" 		# 2015-02-20
function usage () {
local text
	echo -ne "\nUsage:\n\t\e[1m${0##*/} [-d Density] [-c CompressionType] "
	echo -e "[-t Threshold ] [-v] FileName[.pdf]\e[0m"
	echo -e "Produces a pdf file named:\n\t\e[33;1mFileName_mono.pdf\e[0m\n"
echo -e "-d Density\n\tEnsures the quality of resulting image.
\tDefault density: 288. Sane values [144..400]."
echo -e "-c CompressionType\n\tUse the types as defined for imagemagick's convert:
\tGroup4 (default), Fax, JPEG, JPEG2000, Lossless
\tLZW, RLE, ZIP, BZip, or just None.
\tCommand \e[1mconvert -list compress\e[0m
\twill show a full list of compression types."
echo -e "-t Threshold\n\tCould be used to remove light grey spots.
\tBy default, the option is NOT used.
\tValues (0%..100%). Try 80% or 90%."
echo -e "-v\tMake the output verbose."
echo -e "The '-monochrome' option is hardcoded into the conversion command.\n"
}

declare -i DENS 	# Debsity is supposed to be integer.
VERB="" 			# Verbose? No. (default)
THRE="" 			# Threshold (whiten out or enhance)
SIZE="" 			# Resize (0%..100%]

while getopts "vd:c:t:r:hV" flag
do
    case "$flag" in
    	v) VERB="-verbose";;
    	d) DENS="$OPTARG";;
		c) CMPR="$OPTARG";;
		t) THRE="-threshold $OPTARG";;
		r) SIZE="-resize $OPTARG";;
		h) usage; exit;;
		V) echo -e "${0##*/} version ${VERSION}" && exit;;
	esac
done
# Remove the options parsed above.
shift `expr $OPTIND - 1`
(( $# )) || { usage; echo -e "\e[31;1mMissing file name.\e[0m" ; exit;}

DENS=${DENS:-288} 		# the default density of 288
((DENS)) || DENS=288 	# If wrong walue, assume the default value.
CMPR=${CMPR:-Group4} 	# the default compression of Group4
CMPRList=$(echo $(convert -list compress))
[[ $CMPRList =~ (^| )$CMPR($| ) ]] || { echo Wrong compression type.; exit 1;}

f=${1}
[[ -f "$f" ]] || f=${f}.pdf 	# As the pdf extension is optional.
if [[ -f "$f" ]]; then
	nf=$f
	ext=${f##*.}; [[ ${ext,,} = 'pdf' ]] && nf=${nf%.*} #${ext,,} lowercase
	nf=${nf}_mono.pdf
	bn=${f##*/}
	case $LANG in
		pl*) echo Zaczynam pracować!;;
		*) echo Working!
	esac
	echo convert $VERB $SIZE -density $DENS $THRE "$f" -compress $CMPR -monochrome "$nf"
	convert $VERB $SIZE -density $DENS $THRE "$f" -compress $CMPR -monochrome /tmp/"$bn"

	[[ $(which qpdf) ]] && { qpdf -empty -pages /tmp/"$bn" 1-z -- "${nf%.pdf}_meta.pdf";
		rm /tmp/"$bn";} || mv /tmp/"$bn" .

else
	usage
	echo File $f does not exist.
fi
