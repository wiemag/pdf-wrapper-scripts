#!/bin/bash

# Chopping a PDF into chapters
# by dif (wm) 2015-09-03
# A wrapper for qpdf
VERSION=1.01 	# 2015-09-03

function usemsg () {
	echo Syntax:
	echo -e "\t\e[1m${0##*/} filename[.pdf] pages_to_break_after\e[0m"
	echo -e "Where:\n\tpages_to_break_after - integers separated by spaces"
	exit $1
}

hash qpdf 2>/dev/null || {
	echo -e "\n\e[31;1mMissing dependency:\e[0m qpdf\n"
	exit 4
}

n=$#			# number of parameters, including the file name
if (($n < 2)) ; then
	echo -e "\n\e[1m${0##*/}\e[0m (v${VERSION}) chops a PDF."
	echo -e "The original PDF file remains untouched.\n"
	usemsg 1
fi
i=0
nn=0			# non-nunerical entries
while [ $i -lt $n ] ; do
	if (("$1")) 2>/dev/null; then 	# Is $1 numeric and more than 0?
		PAGES[$i]=$1
	else
		if [[ "$1" == '-a' ]]; then
			BURST=TRUE
			#continue parsing to find the pdffile name
			#jump
		else
			((nn++));
			if (( nn > 1 )) ; then
				echo Too many non-numerical entries.
				echo There can be only one file name.
				usemsg 3
			fi
			f=${1%.pdf}	 # PDF-file name to be cut
			if [ ! -e "$f.pdf" ] ; then
				echo File \"$f.pdf\" does not exist.
				exit 1
			fi
		fi
	fi
	((i++))
	shift
done
if (( nn < 1 )); then
	echo Missing file name.
	usemsg 2
fi

# Sorting pages-to-cut-after; "0" added intentionally.
PAGES=($(printf '%s\n' "0 " ${PAGES[@]}|sort -nu))

# Removing a negative page number
while [ ${PAGES[0]} -lt 0 ]; do
	PAGES=("${PAGES[@]:1}")
done

n=${#PAGES[@]}
i=${PAGES[$((n - 1))]}
((i++))

#Removing an out-of-range page number
while [ $i -gt $(qpdf "${f}.pdf" --show-npages) ]; do
	unset PAGES[${#PAGES[@]}-1]
	n=${#PAGES[@]}
	i=${PAGES[$((n - 1))]}
	((i++))
done

PAD=${#i}				# Padding/leading zeros
PAGES=(${PAGES[@]} z) 	# z is the last page

for ((i=0; i<$n ; i++)); do
	p0=$((${PAGES[$i]} +1))
	j=$((i + 1))
	p1=${PAGES[$j]}
	qpdf -empty --pages "${f}.pdf" ${p0}-${PAGES[$j]} -- pdf_$(printf "%0*d" $PAD $p0).pdf
	echo Pages ${p0}-${PAGES[$j]} -- pdf_$(printf "%0*d" $PAD $p0).pdf
done
