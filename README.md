# Whedon

![docs/robot.png](https://github.com/openbases/whedon-python/raw/master/docs/img/robot.png)

> Hi friend! :wave:

[![CircleCI](https://circleci.com/gh/openbases/whedon.svg?style=svg)](https://circleci.com/gh/openbases/whedon)

This is an automated build for a Docker container to serve our favorite, our
friendly robot, the fantastic [whedon](https://www.github.com/openjournals/whedon).
This container serves whedon to build the PDF, but also serves other tests 
to validate the paper.

## Preparation

You should have a submission (suggested in a folder `paper`) called `paper.md`
and a matching `paper.bib`.

```
paper
   paper.md
   paper.bib
```

### Custom Logo

If you want a custom logo, add it to the [paper](paper) directory named as follows:

```
paper
    paper.md
    paper.bib
    logo.png
```

An example is provided here, in [paper](paper). You can read guidelines for the
paper [here](https://joss.readthedocs.io/en/latest/submitting.html).


## Usage

We will also be providing entry points to run tests for a submission, but for
now are just starting with PDF generation. To see full usage, run without
arguments:

```bash
$ docker run --rm -v $PWD/paper:/data openbases/whedon
Usage:

         docker run <options> <container> <action> [options] ...

         **All input files should be mounted as volume at /data in container
         
         Options:

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
```

### Generate PDF

```bash
docker run --rm -v $PWD/paper:/data openbases/whedon pdf
```


### Interactive

```bash
docker run --rm -it -v $PWD/paper:/data --entrypoint bash openbases/whedon
```

The bound "paper" directory is now at "/data"

```bash
root@7d4b53b102f9:/data# ls /data/
img  paper.bib  paper.md
```

## Development

Build the container

```
docker build -t openbases/whedon .
```
