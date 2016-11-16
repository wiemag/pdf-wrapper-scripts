#!/bin/bash
# Imagemagick's convert wrapper.
# Converts PDF's into monochrome PDF's.
# qpdf - optional dependecy
VERSION="1.3"
function usage () {
	echo -e "\nUsage:\n\t\e[1m${0##*/} [-options] FileName[.pdf]\e[0m\n"
	echo -e "Produces a monochrome PDF named:  \e[33;1mFileName_mono.pdf\e[0m\n"
	cat <<OPCJE
Options:

-d Density
      Ensures the quality of resulting image.
      Default density: 288. Sane values [144..400]."
-c CompressionType
      Use the types as defined for imagemagick's convert:
      Group4 (default), Fax, JPEG, JPEG2000, Lossless
      LZW, RLE, ZIP, BZip, or just None.
      Command
         convert -list compress
      will show a full list of compression types.
-t Threshold
      Could be used to remove light grey spots.
      By default, the option is NOT used.
      Values (0%..100%). Try 80% or 90%.
-r Size
      Resize the output according to the Size(%) parameter.
-m
      Limit memory to 2GiB and
      set directory ~/tmp/tmp for temporary files.
-v    makes the output verbose.
OPCJE
echo -e "\n'\e[1m-monochrome\e[0m' option is hardcoded into the conversion command.\n"
}

declare -i DENS 	# Debsity is supposed to be integer.
VERB="" 			# Verbose? No. (default)
THRE="" 			# Threshold (whiten out or enhance)
SIZE="" 			# Resize (0%..100%]
MEM="" 				# Will memory be limited, and temp-files directory created?
TMPD="${HOME}/tmp/tmp"


while getopts "vd:c:t:r:mhV" flag
do
    case "$flag" in
    	v) VERB="-verbose";;
    	d) DENS="$OPTARG";;
		c) CMPR="$OPTARG";;
		t) THRE="-threshold $OPTARG";;
		r) SIZE="-resize $OPTARG";;
		m) MEM="monitor -define registry:temporary-path=$TMPD -limit memory 6GiB -limit map 7GiB";;
		h) usage; exit;;
		V) echo -e "${0##*/} version ${VERSION}" && exit;;
	esac
done
# Remove the options parsed above.
shift `expr $OPTIND - 1`
(( $# )) || { usage; exit;}

DENS=${DENS:-288} 		# the default density of 288
((DENS)) || DENS=288 	# If wrong value, assume the default value.
CMPR=${CMPR:-Group4} 	# the default compression of Group4
CMPRList=$(echo $(convert -list compress))
[[ $CMPRList =~ (^| )$CMPR($| ) ]] || { echo Wrong compression type.; exit 1;}
CMPR='-compress '$CMPR
echo $DENS
while [[ $# -gt 0 ]]; do
	f=${1}
	[[ -f "$f" ]] || f=${f}.pdf 	# As the pdf extension is optional.
	if [[ -f "$f" ]]; then
		nf=$f
		ext=${f##*.}; [[ ${ext,,} = 'pdf' ]] && nf=${nf%.*} #${ext,,} lowercase
		nf=${nf}_mono.pdf
		bn=${f##*/}
		echo convert $MEM $VERB $SIZE -density $DENS $THRE "$f" $CMPR -monochrome "$nf"
		convert $MEM $VERB $SIZE -density $DENS $THRE "$f" $CMPR -monochrome /tmp/"$bn"
#		echo convert $MEM $VERB $SIZE -density $DENS $THRE "$f" tif:- \| convert $CMPR -monochrome "$nf"
#		convert $MEM $VERB $SIZE -density $DENS $THRE "$f" tif:- | convert - -monochrome $CMPR /tmp/"$bn"
		# If qpdf installed, remove meta data.
		hash qpdf 2>/dev/null && { qpdf -empty -pages /tmp/"$bn" 1-z -- "${nf%.pdf}_meta.pdf";
			rm /tmp/"$bn";} || mv /tmp/"$bn" "$nf"
	else
		[[ "$f" =~ '*' ]] && echo Files $f do not exist. || echo File $f does not exist.
	fi
	shift
done;
