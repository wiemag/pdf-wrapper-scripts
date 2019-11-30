#!/bin/bash
# Imagemagick's convert wrapper.
# Converts PDF's into monochrome PDF's.
# qpdf - optional dependecy
VERSION="1.7" # See TempPDF, TempPS
tty -s && TERM=1 || TERM=0 	# Script run from a terminal

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
      Group4, Fax (default), JPEG, JPEG2000, Lossless
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
      Limit memory to 6GiB and
      set directory ~/.tmp for temporary files.
-v    makes the output verbose.
OPCJE
echo -e "\n'\e[1m-monochrome\e[0m' option is hardcoded into the conversion command.\n"
}

declare -i DENS 	# Debsity is supposed to be integer.
VERB="" 			# Verbose? No. (default)
THRE="" 			# Threshold (whiten out or enhance)
SIZE="" 			# Resize (0%..100%]
MEM="" 				# Will memory be limited, and temp-files directory created?
TMPD="${HOME}/.tmp" # Temporary path set for big files


while getopts "vd:c:t:r:mhV" flag
do
    case "$flag" in
    	v) VERB="-verbose";;
    	d) DENS="$OPTARG";;
	c) CMPR="$OPTARG";;
	t) THRE="-threshold $OPTARG";;
	r) SIZE="-resize $OPTARG";;
	m) MEM="-monitor -define registry:temporary-path=$TMPD -limit memory 6GiB -limit map 6GiB"; [[ -e $TMPD ]] || { mkdir -p $TMPD;} ;;
	h) usage; exit;;
	V) echo -e "${0##*/} version ${VERSION}" && exit;;
    esac
done
# Remove the options parsed above.
shift `expr $OPTIND - 1`
(( $# )) || { usage; exit;}

# If the script is not run from a Terminal, set the threshold to 78%.
DENS=${DENS:-288} 		# the default density of 288
((DENS)) || { DENS=288; echo Wrong density; the default one assumed.;}
CMPR=${CMPR:-Group4} 	# the default compression of Group4
CMPRList=$(echo $(convert -list compress))
[[ $CMPRList =~ (^| )$CMPR($| ) ]] || { echo Wrong compression type.; exit 1;}
CMPR='-compress '$CMPR
[[ $TERM -eq 1 ]] && {
	echo density=${DENS};
	echo compress=${CMPR};
} || {
	THRE="-threshold 78%";
	notify-send "${0##*/} ${1}" "Options: ${THRE} -density ${DENS} ${CMPR}" --icon=dialog-information;
}
TempPDF=$(mktemp)
TempPS=$(mktemp)
while [[ $# -gt 0 ]]; do
	f=${1}
	[[ -f "$f" ]] || f=${f}.pdf 	# As the pdf extension is optional.
	if [[ -f "$f" ]]; then
		nf=$f
		ext=${f##*.}; [[ ${ext,,} = 'pdf' ]] && nf=${nf%.*} #${ext,,} lowercase
		nf=${nf}_mono.pdf
		bn=${f##*/}
		[[ $TERM -eq 1 ]] && {
			echo DEBUG: \$nb=${bn};
			echo convert $MEM $VERB $SIZE -density $DENS $THRE -monochrome "$f" $CMPR "$nf";
		}
		convert $MEM $VERB $SIZE -density $DENS $THRE "$f" $CMPR -monochrome "$TempPDF"
#		echo convert $MEM $VERB $SIZE -density $DENS $THRE -monochrome "$f" tif:- \| convert $CMPR "$nf"
#		convert $MEM $VERB $SIZE -density $DENS $THRE -monochrome "$f" tif:- | convert - $CMPR "$TempPDF"
		# If error in resultant file, repair it by repackaging it with pdftops and ps2pdf.
		gs -dBATCH -dNOPAUSE -sDEVICE=nullpage "$TempPDF" |grep 'Error\|error' && {
			pdftops "$TempPDF" "$TempPS";
			ps2pdf "$TempPS" "$TempPDF";
			rm "$TempPS";
		}
		# If qpdf installed, remove meta data.
		hash qpdf 2>/dev/null && { qpdf -empty -pages "$TempPDF" 1-z -- "${nf%.pdf}_meta.pdf";
			rm "$TempPDF";
		} || mv "$TempPDF" "$nf"
	else
		[[ "$f" =~ '*' ]] && echo Files $f do not exist. || echo File $f does not exist.
	fi
	shift
done;
