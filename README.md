# Open Bases Paper Base

![docs/img/logo-small.png](https://github.com/openbases/openbases-pdf/raw/master/img/logo-small.png)

> Hi friend! :wave:

This is an automated build for a Docker container to build you a paper! 
If you want to use the builder for your repository, you can read full
instructions at [openbases/builder-pdf](https://www.github.com/openbases/builder-pdf).

## Usage

You can build your pdf locally! Here is how to look at usage:

```bash
$ docker run openbases/openbases-pdf

Usage:

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
```

Now since we want to generate a PDF, we would specify "pdf" as the first argument
to the entrypoint. If we don't bind any folders, we can specify a demo 
provided in the container.

```bash
$ docker run openbases/openbases-pdf pdf 
```

If you want to bind the output folder to your computer to see what is generated,
you can do that!

```bash
mkdir -p output
docker run -v $PWD/output:/data openbases/openbases-pdf pdf
vanessa@vanessa-ThinkPad-T460s:~/Documents/Dropbox/Code/openbases/openbases-pdf$ tree output/
output/
├── paper.bib
├── paper.md
└── paper.pdf
```

But likely you want to specify your own input files! Let's do that. In the folder
paper in the present working directory we have a paper.md and paper.bib. Let's
see if this still generates the proper output.

```bash
rm output/*
```
```
docker run -v $PWD/paper:/data openbases/openbases-pdf pdf
$ tree output/
output/
├── paper.bib
├── paper.md
└── paper.pdf
```

And remember that you can customize all of these variables - the default
simply intends (or tries) to make this easiest for you!

```
  --md: pdf input markdown file (default paper.md)
  --bib: custom bib file (default paper.bib)
  --minimal: create a minimal pdf (no template, etc.)
  --logo: add a 'logo.png' to the same directory as your paper
  --name: customize the name of the resulting pdf (default paper.pdf)
  --template: use a custom template (put in mounted /data)
```

## Development

Build the container locally. See [openbases/builder-pdf](https://www.github.com/openbases/builder-pdf)
for usage.

```bash
docker build -t openbases/openbases-pdf .
```

Have a question or need help? Please [open an issue](https://www.github.com/openbases/openbases-pdf/issues)
