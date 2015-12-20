#!/bin/bash

# Re-arrangind page order in a PDF
# by dif (wm) 2015-12-20
# A wrapper for qpdf

hash qpdf 2>/dev/null || {
	echo -e "\n\e[31;1mMissing dependency:\e[0m qpdf\n"
	exit 4
}
VERSION=1.0 	# 2015-12-20
INPLACE=0 		# Play it safe.

function usemsg () {
	echo Syntax:
	echo -e "\t\e[1m${0##*/} [-i] input_file page-order\e[0m\n"
cat <<OPCJE
Unless -i is used, input_file_mixed.pdf is created.

-i  "inplace" page reordering. Like sed's -i option.
<page-order> redefines page order and defines a set of pages for the new PDF.

Use
   coma-separated (,) or dash-sepatared (-) page numebers
   z for the last page
   2-8 defines a range of pages
   8-2 defines a reverse range of pages

Example: 7,5-3,1 defines the following set of pages 7,5,4,3,1.

WARNING!
You cannot repeat the same number or have it covered by a defined range.

OPCJE
}

[[ $1 = '-i' ]] && { shift; INPLACE=1;}
n=$#			# number of parameters, including the file name
if (($n != 2)) ; then
	usemsg
else
	qpdf -empty --pages "$1" $2 -- "${1%.pdf}_mixed.pdf"
	[[ $? -eq 0 ]] && [[ $INPLACE -eq 1 ]] && mv "${1%.pdf}_mixed.pdf" "$1" || :
fi
