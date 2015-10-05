#!/bin/bash
IN="$S1"
#gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="${IN%.pdf}_unencrypted.pdf" -c .setpdfwrite -f "$IN"
gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="unencrypted.pdf" -c .setpdfwrite -f "$IN"
