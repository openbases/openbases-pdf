FROM ubuntu:18.04
# docker build -t openbases/whedon .

LABEL maintainer "@vsoch"
ENV DEBIAN_FRONTEND noninteractive
ENV WHEDON_DIR=/opt/whedon

RUN apt update && \
    apt install --yes --no-install-recommends \
       git \
       biber \
       build-essential \
       lmodern \
       pandoc \
       pandoc-citeproc \
       python-setuptools \
       python-pip \
       texlive-xetex \
       texlive \
       texlive-latex-extra \
       texlive-bibtex-extra \
       texlive-fonts-recommended \
       wget && \
    wget -O /tmp/pandoc.deb https://github.com/jgm/pandoc/releases/download/2.1.1/pandoc-2.1.1-1-amd64.deb && \
    dpkg -i /tmp/pandoc.deb && \
    git clone https://github.com/openjournals/whedon.git "${WHEDON_DIR}" && \
    mkdir -p /data /code  && \
    pip install --upgrade pip && \
    pip install whedon

ADD . /code
RUN chmod u+x /code/entrypoint.sh
WORKDIR /data

ENTRYPOINT ["/bin/bash", "/code/entrypoint.sh"]
