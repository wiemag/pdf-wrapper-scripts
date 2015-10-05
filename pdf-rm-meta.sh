#!/bin/bash -
# Removes meta data form PDFs
hash qpdf 2>/dev/null || {
	echo -e "\n\e[31;1mMissing dependency:\e[0m qpdf\n"
	exit 1
}
INPUT="${1-}"
[[ -f "$INPUT" ]] || { echo -e "\n${0##*/} <input.pdf> [<output>.pdf]"; exit;}
OUTPUT="${2-${INPUT%.pdf}_meta.pdf}"
qpdf -empty -pages "$INPUT" 1-z -- "$OUTPUT"
