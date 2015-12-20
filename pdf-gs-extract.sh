#!/bin/bash
# Extract a range of pages with gs
# Modified from http://www.linuxjournal.com/content/tech-tip-extract-pages-pdf

# Checking dependencies
hash gs 2>/dev/null || {
	echo Missing dependency: gs
	exit 1
}
function usage(){
	echo -e "\n${0##*/} input_file first_page last_page\n"
}
function pdfpextr(){
 # this function uses 3 arguments:
 # $1 is the input file
 # $2 is the first page of the range to extract
 # $3 is the last page of the range to extract
 # output file will be named "inputfile_pXX-pYY.pdf"
 gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
    -dFirstPage=${2} \
    -dLastPage=${3} \
    -sOutputFile="${1%.pdf}_p${2}-p${3}.pdf" \
    "${1}"
}

[[ $# -eq 3 ]] && pdfpextr "$1" $2 $3 || usage
