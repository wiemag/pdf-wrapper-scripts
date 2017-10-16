#!/bin/bash
# Removes meta data form PDFs

# Check dependencies
for DEP in pdftk awk sed; do
hash pdftk 2>/dev/null || {
	echo -e "\n\e[31;1mMissing dependency:\e[0m package for ${DEP}\n"
	exit 1
}
done

VERSION=2.0
USAGE="\nUsage:\n"
USAGE="${USAGE}\t${0##*/} [-o OUTPUT] [-c] input1 [input2 [input3 [...]]]\n\n"
USAGE=${USAGE}'-o\tIf used, only the first input file is processed.\n'
USAGE=${USAGE}'\tIf not used, _no-meta.pdf suffix added to input file names.\n'
USAGE=${USAGE}'-c\tRename OUTPUT back into INPUT orginal file name.\n'
OUTMODE=0
INPLACE=0

# Parse dash-options
while getopts o:c?hv OPT; do
    case "$OPT" in
        h|\?) echo -e $USAGE; exit;;
        v) echo ${0##*/}, version $VERSION; exit;;
        o) OUTPUT=$OPTARG; OUTMODE=1;;
        c) CLEAN=1;;
    esac
done
shift $(expr $OPTIND - 1)

[[ $# -lt 1 ]]  && { echo -e $USAGE; exit;}

for INPUT in $@; do
	if [[ -f "$INPUT" ]]; then
		if [[ $(file -b "$INPUT" |cut -d\  -f1) == 'PDF' ]]; then
			[[ $OUTMODE -eq 0 ]] && OUTPUT="${INPUT%.pdf}_no-meta.pdf"
			pdftk "$INPUT" dump_data_utf8| \
				sed -n '1,/NumberOfPages:/'p| \
				awk '/Info/' | \
				sed 's/InfoValue: .*/InfoValue:/g' > "/tmp/${USER}-${INPUT}_meta.txt"
			pdftk "$INPUT" update_info_utf8 "/tmp/${USER}-${INPUT}_meta.txt" \
				output "$OUTPUT"
			[[ $CLEAN -eq 1 ]] && { mv "$OUTPUT" "$INPUT";
				rm "/tmp/${USER}-${INPUT}_meta.txt";
			}
		else
			echo "[!] '$INPUT' is not a PDF."
		fi
	else
		echo -e "File '$INPUT' does not exist."
	fi
	[[ $OUTMODE -eq 1 ]] && exit || :
done
