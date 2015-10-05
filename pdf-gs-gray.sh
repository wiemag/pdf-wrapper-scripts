#!/bin/bash

IN="$1"
[[ -f "$IN" ]] || { echo Input file does not exist.; exit 1;}
gs \
-sOutputFile="${IN%.pdf}"_gray.pdf \
-sDEVICE=pdfwrite \
-sColorConversionStrategy=Gray \
-dProcessColorModel=/DeviceGray \
-dCompatibilityLevel=1.4 \
-dAutoRotatePages=/None \
-dNOPAUSE \
-dBATCH \
"$IN"
