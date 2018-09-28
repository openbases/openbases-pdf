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
```

Now since we want to generate a PDF, we would specify "pdf" as the first argument
to the entrypoint:

```bash
docker run openbases/openbases-pdf pdf /data/paper.md "${OPENBASES_PAPER_ARGS}"
```

## Development

Build the container locally. See [openbases/builder-pdf](https://www.github.com/openbases/builder-pdf)
for usage.

```bash
docker build -t openbases/openbases-pdf .
```
