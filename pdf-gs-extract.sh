#!/bin/bash
# Extract a range of pages with gs
# Copy from http://www.linuxjournal.com/content/tech-tip-extract-pages-pdf

# Checking dependencies
hash gs 2>/dev/null || {
	echo Missing dependency: gs
	exit 1
}

function pdfpextr()
{
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

pdfpextr "$1" $2 $3 	#file, start page, end page
