#!/bin/bash

WHEDON_DIR=${WHEDON_DIR:-/opt/whedon}

exec pandoc -o paper.pdf -V geometry:margin=1in --filter pandoc-citeproc paper.md --template "${WHEDON_DIR}"/resources/latex.template --variable formatted_doi=pending -V joss_logo_path="${WHEDON_DIR}"/resources/joss-logo.png --pdf-engine=xelatex
