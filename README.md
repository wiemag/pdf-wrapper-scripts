PDF wrapper scripts
---------------------

Scripts that simplify the usual commands related to creating and processing PDF files.

Small utility bash scripts.
- jpg2pdf.sh          - converting JPEG's into monochrome PDF's
- pdf2pdf_mono.sh     - convert a PDF file into a monochrome PDF file
- pdf-chopper.sh      - splitting PDF's into smaller PDF's (qpdf based)
- pdf-tk-chopper.sh   - splitting PDF's into smaller PDF's (pdftk based)
- pdf-joiner.sh       - joining DPF's into a single PDF (qpdf based)
- pdf-rm-meta.sh      - remove meta data from a pdf file (qpdf based)
- pdf-tk-rm-meta.sh   - the same as above, different tool used (pdftk based)
- pdf-a4.sh           - resize into the A4 format
- pdf-rot.sh          - a simplified and limited pdftk wrapper; rotates pages
- pdf-odd+even.sh     - join odd and even pages into a pdf book
- pdf-gs-repair.sh    - try to repair a PDF file by reprinting by gs
- pdf-gs-extract.sh
- pdf-gs-gray.sh
- pdf-gs-decrypt.sh
- pdfcrop-wm.sh       - a pdfcrop wrapper (checks files and reminds usage)

INSTALLATION

The scripts here use are based either on 'qpdf' or 'pdftk'.
Additional dependencies may include
- imagemagick
- graphycsmagick
- gs
- poppler
- texlive-core

No installation, just download and use.
