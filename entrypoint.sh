#!/bin/bash

WHEDON_DIR=${WHEDON_DIR:-/opt/whedon}

#!/bin/bash

usage () {

    echo "Usage:

         docker run <options> <container> <action>

         **All input files should be mounted as volume at /data in container

         Actions:

                pdf: generate a whedon (Joss) PDF (special formatting) default
         
         Options (pdf):

               --minimal: create a minimal pdf (no template, etc.)

         Customize:
             logo: add a 'logo.png' to the same directory as your paper

         Examples:

              docker run -v $PWD:/data <container> pdfplain

         "
}

if [ $# -eq 0 ]; then
    usage
    exit
fi

# These should be mounted at /data
PDF_TYPE="pdf"

while true; do
    case ${1:-} in
        -h|--help|help)
            usage
            exit
        ;;
        --minimal|minimal)
            shift
            PDF_TYPE="minimal"
        ;;
        -*)
            echo "Unknown option: ${1:-}"
            exit 1
        ;;
        *)
            break
        ;;
    esac
done

# If we don't have a logo, copy from joss
if [ ! -f "logo.png" ]
    then
    echo "No custom logo.png found, copying whedon's from joss"
    echo "cp ${WHEDON_DIR}/resources/joss-logo.png logo.png"
    cp ${WHEDON_DIR}/resources/joss-logo.png logo.png
fi


if [ "${PDF_TYPE}" == "minimal" ]; then

    echo "Producing minimal pdf."
    echo "pandoc paper.md --filter pandoc-citeproc --bibliography paper.bib -o paper.pdf"
    pandoc "/data/${PDF_FILE}" --filter pandoc-citeproc --bibliography "/data/${PDF_BIB}" -o "${PDF_OUTFILE}"
    
else

    authors=$(py-whedon get paper.md authors:name)
    title=$(py-whedon get paper.md title)
    repo=$(py-whedon get paper.md repo)
    archive_doi=$(py-whedon get paper.md archive_doi)
    formatted_doi=$(py-whedon get paper.md formatted_doi)
    paper_url=$(py-whedon get paper.md paper_url)
    review_issue_url=$(py-whedon get paper.md review_issue_url)

    exec /usr/bin/pandoc \
        -V paper_title="$(title)" \
        -V footnote_paper_title="$(title)" \
        -V citation_author="$(authors)" \
        -V repository="$(repo)" \
        -V archive_doi="http://dx.doi.org/10.21105/zenodo.1400822" \
        -V formatted_doi="10.21105/joss.00850" \
        -V paper_url="http://joss.theoj.org/papers/" \
        -V review_issue_url="https://github.com/openjournals/joss-reviews/issues/$(issue)" \
        -V issue="$(issue)" \
        -V volume="$(vol)" \
        -V year="$(year)" \
        -V submitted="$(submitted)" \
        -V published="$(accepted)" \
        -V page="$(issue)" \
        -V graphics="true" \
        -V logo_path="logo.png" \
        -V geometry:margin=1in \
        --verbose \
        -o paper.tex \
        --pdf-engine=xelatex \
        --filter /usr/bin/pandoc-citeproc paper.md \
        --from markdown+autolink_bare_uris \
        --template "latex.template"


    pandoc -o "/data/${PDF_OUTFILE}" -V geometry:margin=1in --filter pandoc-citeproc "/data/${PDF_FILE}" --template ${WHEDON_DIR}/resources/latex.template --variable formatted_doi=pending -V joss_logo_path=${WHEDON_DIR}/resources/joss-logo.png --pdf-engine=xelatex

fi
