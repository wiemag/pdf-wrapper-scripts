#!/bin/bash
# Repair a repairable PDF.
#
CORRUPTED="$1"
REPAIRED=${CORRUPTED%.pdf}
REPAIRED=${REPAIRED%.PDF}_repaired.pdf
if [[ -f "$CORRUPTED" ]]; then
	gs -o "$REPAIRED" \
	-sDEVICE=pdfwrite -dPDFSETTINGS=/prepress "$CORRUPTED"
fi
