#!/bin/bash

usage () {

    echo "Usage:


         docker run <options> <container> <action> [options] ...
         docker run -v /data:/data <container> pdf

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

             --issue: Github issue of associated review
             --year: year for publication
             --volume: volume for publication

         Examples:

              docker run -v /data:/data <container> pdf --minimal
         "
}

get_default() {

    # Check if the variable provided by the user is defined. If not,
    # return default

    CUSTOM_PATH="${1}"
    CUSTOM_TYPE="${2}"
    CUSTOM_DEFAULT="${3}"

    if [ -f "${CUSTOM_PATH}" ]; then
        1>&2 echo "[${CUSTOM_TYPE}] ${CUSTOM_PATH}"
    else
        # Second try, look in data
        if [ -f "/data/${CUSTOM_PATH}" ]; then
            CUSTOM_PATH="/data/${CUSTOM_PATH}"
        else
            1>&2 echo "Warning, cannot find ${CUSTOM_PATH}, using default."
            CUSTOM_PATH="${CUSTOM_DEFAULT}"
        fi
    fi
    printf $CUSTOM_PATH
}

if [ $# -eq 0 ]; then
    usage
    exit
fi


# These should be mounted at /data
PDF_BIB="paper.bib"
PDF_INFILE="paper.md"
PDF_OUTFILE="paper.pdf"
PDF_LOGO="/data/logo.png"
PDF_TEMPLATE="/data/latex.template.joss"
PDF_TYPE="pdf"

# Preference to svg
if [ -f "/data/logo.svg" ]; then
    PDF_LOGO="/data/logo.svg"
fi

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
        --logo|logo)
            shift
            PDF_LOGO="${1:-}"
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

PDF_TEMPLATE=$(get_default "${PDF_TEMPLATE}" "template" "/data/latex.template.joss")

if [ ! -f "${PDF_LOGO}" ]; then

    echo "Cannot find logo, generating cuteness!"
    OPENBASES_ICON_URL=$(ob-icons)
    OPENBASES_ICON=/tmp/$(basename ${OPENBASES_ICON_URL})
    wget "${OPENBASES_ICON_URL}" -O ${OPENBASES_ICON}

    # Fall back to openbases logo
    if [ ! -f "${OPENBASES_ICON}" ]; then
        PDF_LOGO="/data/openbases-logo.png"
    else
        PDF_LOGO="${OPENBASES_ICON}"
    fi
fi

# Generate ---------------------------------------------------------------------

# The output file must go to /data
PDF_OUTFILE=$(basename "${PDF_OUTFILE}")

if [ "${PDF_TYPE}" == "minimal" ]; then

    echo "Producing minimal pdf."
    echo "pandoc paper.md --filter pandoc-citeproc --bibliography paper.bib -o paper.pdf"
    pandoc "/data/${PDF_FILE}" --filter pandoc-citeproc --bibliography "/data/${PDF_BIB}" -o "${PDF_OUTFILE}"
    
else

    authors=$(ob-paper get paper.md authors:name)
    title=$(ob-paper get paper.md title)
    repo=$(ob-paper get paper.md repo)
    archive_doi=$(ob-paper get paper.md archive_doi)
    formatted_doi=$(ob-paper get paper.md formatted_doi)
    paper_url=$(ob-paper get paper.md paper_url)
    review_issue_url=$(ob-paper get paper.md review_issue_url)
    
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
        -V logo_path="${PDF_LOGO}" \
        -V geometry:margin=1in \
        --verbose \
        -o "/data/${PDF_OUTFILE}" \
        --pdf-engine=xelatex \
        --filter /usr/bin/pandoc-citeproc ${PDF_INFILE} \
        --from markdown+autolink_bare_uris \
        --template "${PDF_TEMPLATE}"

fi
