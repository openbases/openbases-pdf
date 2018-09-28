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
    CUSTOM_BASENAME=$(basename "${CUSTOM_PATH}")

    if [ -f "${CUSTOM_PATH}" ]; then
        1>&2 echo "[${CUSTOM_TYPE}] ${CUSTOM_PATH}"
    else
        # Second try, look in data
        if [ -f "/data/${CUSTOM_PATH}" ]; then
            CUSTOM_PATH="/data/${CUSTOM_PATH}"
        # Third try, basename in /data
        elif [ -f "/data/${CUSTOM_BASENAME}" ]; then
            CUSTOM_PATH="/data/${CUSTOM_BASENAME}"
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
PDF_BIB="/data/paper.bib"
PDF_OUTFILE="paper.pdf"
PDF_LOGO="/data/logo.png"
PDF_TEMPLATE="/code/paper/latex.template.joss"
PDF_INFILE="/data/paper.md"
PDF_TYPE="pdf"

# Preference to svg
if [ -f "/data/logo.svg" ]; then
    echo "Warning: svg not supported! Please convert to png."
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
PDF_INFILE=$(get_default "${PDF_INFILE}" "markdown" "/code/paper/paper.md")
PDF_BIB=$(get_default "${PDF_BIB}" "bibliography" "/code/paper/paper.bib")

if [ ! -f "${PDF_LOGO}" ]; then

    echo "Cannot find logo, generating cuteness!"
    OPENBASES_ICON_URL=$(ob-icons)
    OPENBASES_ICON=/tmp/$(basename ${OPENBASES_ICON_URL})
    wget "${OPENBASES_ICON_URL}" -O ${OPENBASES_ICON}

    # Fall back to openbases logo
    if [ ! -f "${OPENBASES_ICON}" ]; then
        PDF_LOGO="/code/paper/openbases-logo.png"
    else
        PDF_LOGO="${OPENBASES_ICON}"
    fi
fi

# Generate ---------------------------------------------------------------------

# The output file must go to /data
PDF_OUTFILE=$(basename "${PDF_OUTFILE}")

# Copy bib and paper to same folder
cp "${PDF_INFILE}" /data/paper.md
cp "${PDF_BIB}" /data/paper.bib

if [ "${PDF_TYPE}" == "minimal" ]; then

    echo "Producing minimal pdf."
    echo "pandoc ${PDF_INFILE} --filter pandoc-citeproc --bibliography ${PDF_BIB} -o ${PDF_OUTFILE}"
    pandoc "${PDF_INFILE}" --filter pandoc-citeproc --bibliography "${PDF_BIB}" -o "${PDF_OUTFILE}"
    
else

    authors=$(ob-paper get ${PDF_INFILE} authors:name)
    title=$(ob-paper get ${PDF_INFILE} title)
    repo=$(ob-paper get ${PDF_INFILE} repo)
    archive_doi=$(ob-paper get ${PDF_INFILE} archive_doi)
    formatted_doi=$(ob-paper get ${PDF_INFILE} formatted_doi)
    paper_url=$(ob-paper get ${PDF_INFILE} paper_url)
    review_issue_url=$(ob-paper get ${PDF_INFILE} review_issue_url)
    
    /usr/bin/pandoc \
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
        --filter /usr/bin/pandoc-citeproc "/data/paper.md" \
        --from markdown+autolink_bare_uris \
        --template "${PDF_TEMPLATE}"

fi

# Fix permissions
chmod 0777 /data/*
echo "Files generated:"
tree /data
