# Whedon

This is an automated build for a Docker container to serve our favorite, our
friendly robot, the fantastic [whedon](https://www.github.com/openjournals/whedon).

## Usage
You should have a submission (suggested in a folder `paper`) called `paper.md`
and a matching `paper.bib`.

```
paper
   paper.md
   paper.bib
```

An example is provided here, in [paper](paper). You can read guidelines for the
paper [here]().

## Interactive

Here is how to test interactively! First build the container (or just run to pull 
it)

```
docker build -t openbases/whedon .
```

and shell in interactively:

```
docker run -it -v $PWD/paper:/data --entrypoint bash openbases/whedon
```

The bound "paper" directory is now at "/data"

```
root@7d4b53b102f9:/data# ls /data/
img  paper.bib  paper.md
```

**under development**
