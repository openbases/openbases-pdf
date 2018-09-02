#!/bin/bash

WHEDON_DIR=${WHEDON_DIR:-/opt/whedon}

#!/bin/bash

usage () {

    echo "Usage:


         docker run <options> <container> <action> [options] ...

         **All input files should be mounted as volume at /data in container
         
         Action [pdf] Options:

         pdf:

             --md: pdf input markdown file (default paper.md)
             --bib: custom bib file (default paper.bib)
             --minimal: create a minimal pdf (no template, etc.)
             --logo: add a 'logo.png' to the same directory as your paper
             --name: customize the name of the resulting pdf (default paper.pdf)
             --template: use a custom template (put in mounted /data)

         pub:

             --issue: Github issue at joss-reviews of associated review
             --year: JOSS year for publication
             --volume: JOSS volume for publication

         Examples:

              docker run -v /data:/data <container> pdf --minimal
         "
}

if [ $# -eq 0 ]; then
    usage
    exit
fi


# These should be mounted at /data
PDF_BIB="paper.bib"
PDF_INFILE="paper.md"
PDF_OUTFILE="paper.pdf"
PDF_TEMPLATE="/data/latex.template"
PDF_TYPE="pdf"

while true; do
    case ${1:-} in
        -h|--help|help)
            usage
            exit
        ;;
        --bib|bib)
            shift
            PDF_BIB="${1:-}"
            shift
        ;;
        --issue|issue)
            shift
            issue="${1:-}"
            shift
        ;;
        --name|name)
            shift
            PDF_OUTFILE="${1:-}"
            shift
        ;;
        --volume|volume)
            shift
            volume="${1:-}"
            shift
        ;;
        --year|year)
            shift
            year="${1:-}"
            shift
        ;;
        --md|md)
            shift
            PDF_INFILE="${1:-}"
            shift
        ;;
        --minimal|minimal)
            shift
            PDF_TYPE="minimal"
        ;;
        --template|template)
            shift
            PDF_TEMPLATE="${1:-}"
            shift
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

# Template ---------------------------------------------------------------------

# Default we will use (and give to user) whedon's
cp ${WHEDON_DIR}/resources/latex.template /data/latex.template

# But the user can provide a custom template
# If we don't have a template, also copy
if [ ! -z "$PDF_TEMPLATE" ]; then
    if [ -f "${PDF_TEMPLATE}" ]; then
        echo "[custom template] ${PDF_TEMPLATE}"
    else
        echo "Warning, cannot find ${PDF_TEMPLATE}, using default."
    fi
fi


# Logo -------------------------------------------------------------------------

# If we don't have a logo, copy from joss

if [ ! -f "logo.png" ]; then
    echo "No custom logo.png found, copying whedon's from joss"
    echo "cp ${WHEDON_DIR}/resources/joss-logo.png logo.png"
    cp ${WHEDON_DIR}/resources/joss-logo.png logo.png
fi


# Generate ---------------------------------------------------------------------

# The output file must go to /data
PDF_OUTFILE=$(basename "${PDF_OUTFILE}")

if [ "${PDF_TYPE}" == "minimal" ]; then

    echo "Producing minimal pdf."
    echo "pandoc paper.md --filter pandoc-citeproc --bibliography paper.bib -o paper.pdf"
    pandoc "/data/${PDF_FILE}" --filter pandoc-citeproc --bibliography "/data/${PDF_BIB}" -o "${PDF_OUTFILE}"
    
else

    authors=$(py-whedon paper get paper.md authors:name)
    title=$(py-whedon paper get paper.md title)
    repo=$(py-whedon paper get paper.md repo)
    archive_doi=$(py-whedon paper get paper.md archive_doi)
    formatted_doi=$(py-whedon paper get paper.md formatted_doi)
    paper_url=$(py-whedon paper get paper.md paper_url)
    review_issue_url=$(py-whedon paper get paper.md review_issue_url)
    
    exec /usr/bin/pandoc \
        -V paper_title="${title}" \
        -V footnote_paper_title="${title}" \
        -V citation_author="${authors}" \
        -V repository="${repo}" \
        -V archive_doi="${archive_doi}" \
        -V formatted_doi="${formatted_doi}" \
        -V paper_url="http://joss.theoj.org/papers/" \
        -V review_issue_url="https://github.com/openjournals/joss-reviews/issues/${issue}" \
        -V issue="${issue}" \
        -V volume="${vol}" \
        -V year="${year}" \
        -V submitted="${submitted}" \
        -V published="${accepted}" \
        -V page="${issue}" \
        -V graphics="true" \
        -V logo_path="logo.png" \
        -V geometry:margin=1in \
        --verbose \
        -o "/data/${PDF_OUTFILE}" \
        --pdf-engine=xelatex \
        --filter /usr/bin/pandoc-citeproc ${PDF_INFILE} \
        --from markdown+autolink_bare_uris \
        --template "latex.template"

fi
