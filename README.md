# Whedon

![docs/robot.png](https://github.com/openbases/whedon-python/raw/master/docs/img/robot.png)

> Hi friend! :wave:

[![CircleCI](https://circleci.com/gh/openbases/whedon.svg?style=svg)](https://circleci.com/gh/openbases/whedon)

This is an automated build for a Docker container to serve our favorite, our
friendly robot, the fantastic [whedon](https://www.github.com/openjournals/whedon).
This container serves whedon to build the PDF, but also serves other tests 
to validate the paper. You can fork the repository to have an automated build
(or preview) of your paper! Let's get started:

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

## Local Usage

You can use this container to build and preview a pdf for your submission to
an open journals journal. The container is ready for you to go, pre-built on
Docker Hub as [openbases/whedon](https://hub.docker.com/r/openbases/whedon/) and you
can even look at [tags, manifests, pdfs, and changes over time](https://openbases.github.io/whedon/) for the
this container. 

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

You can customize any of these input arguments by way of adding the flags shown
in the command above.

### Generate PDF

Here is the "use all defaults" generation command:

```bash
docker run -v $PWD/paper:/data openbases/whedon pdf
```

### Interactive

Here is how you might want to shell inside the container to use the software (e.g.,
whedon is at `/opt/whedon` and `pandoc` is installed.

```bash
docker run -it -v $PWD/paper:/data --entrypoint bash openbases/whedon
```

The bound "paper" directory is now at "/data"

```bash
root@7d4b53b102f9:/data# ls /data/
img  paper.bib  paper.md
```

## Automated Usage

But wouldn't it be cooler to have your own whedon repository, meaning a [paper](paper)
folder in your repository that, when you build each time, will run whedon,
generate the outputs, and then upload them back to Github pages? Yep, we think so
too! In this case, you can clone the entire repository, and continue with the steps below.

## Getting Started

Today you will be doing the following:

  1.  Fork and clone the continuous-build Github repository to obtain
      the hidden `.circleci` folder.
  2.  connecting your repository to CircleCI
  3.  creating a Github Machine User account to deploy back to Github Pages
  4.  push, commit, or create a pull request to trigger a build.

You don't need to install any dependencies on your host to use the whedon container,
it will be done on a continuous integration server, and  If you add a Machine
user (step 4) your paper will be deployed back
to Github pages, for the record. If not, you can just preview it as an artifact,
which is still very useful.

### Step 1. Clone the Repository

First, fork the [whedon](https://www.github.com/openbases/whedon/)
Github repository to your account, and clone the branch.

```bash
git clone https://www.github.com/<username>/whedone
git clone git@github.com:<username>/whedon.git
```

### Step 2. Configuration

The hidden folder [.circleci/config.yml](.circleci/config.yml) has instructions for
[CircleCI](https://circleci.com/dashboard/) to automatically discover
and build your paper. If you choose to deploy back to Github pages, there is 
also a [template.html](template.html) file that is used as a template. 
The first does most of the steps required for build and deploy, including:

 1.  clone of the repository with your paper folder
 2.  build the latest whedon container
 3.  generate a pdf, archive, and manifests and inspections
 4.  (optional) push back to Github pages

Thus, if you have forked the repository and cloned your fork, you should be able to use
the files that are pulled. And if you are an advanced user, you could even customize if you
want.

### Step 3. Generation

This happens all in the CI, and is ready to go for you! If you go under the "build"
step in your workflow, you can click on the "artifacts" tab to see your paper outputs.

We will also be providing a template that starts at step 3, so you don't need to wait
for the whedon container to build (under development!)

### Step 4. (optional) Github Machine User

If you want to deploy the manifests and paper back to Github pages, the easiest option (and
one that doesn't put your entire Github account under risk) is to create a machine
user. This comes down to creating a second Github user account (with a different email)
and then giving the account permission to the repository, and generate an ssh key for it.
You won't need to worry about how the deploy is done - this is handled in the circleCI
recipe included with the template. Here are instructions for setting up credentials, derived
from [this great resource](https://github.com/DevProgress/onboarding/wiki/Using-Circle-CI-with-Github-Pages-for-Continuous-Delivery).

**Why do I need to do this?**

Pushing content back to Github pages requires a deploy key. Although Circle will generate a deploy key for you, it only has read access. We need to generate a machine user with write access. Read more about machine user keys [keys](https://circleci.com/docs/github-security-ssh-keys/#machine-user-keys)

**Instructions**

 1. Open a second browser so you can stay logged into your main Github account in one browser, and [create a new Github account](https://github.com/join) there. You will basically need another email address, and a creative username.
 2. In your main Github account (the primary browser) add this user as a collaborator to your repository. They will need push access.
 3. Accept the invitation in the second browser, or the emali sent to you.
 4. In the second browser, again log in to [Circle CI](https://circleci.com/) with your new Github account. Make sure you log in via your Github machine user account, and that you have accepted the invitation.
 5.  Click on "Add Projects", and select your regular Github username under "Choose Organization". This is the owner of the project.  Then click "Follow Project" next to the repository name on the left of the menu. 
 6. This is important! Once followed, go to the Project Settings -> "Checkout SSH keys", and click on the button to "Authorize with GitHub." You will be taken back to Github, signed in as the machine user, and you should click "Authorize Application." Finally, click the Create and add machine user github name key button on the same page.

**Generate Key**
Follow the instructions [here](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key) to generate a new ssh key. The steps to add it to your project are a little weird, but I'll try to be specific:

 - your machine user must first be added as a collaborator to the project
 - you must then log in to CircleCI with your **machine user** and click on Jobs to see the project
 - when you see it, click on any of the steps and click on "Follow Project" in the upper right
 - Under the project settings (gear icon in the upper right) under "Permissions" click on "Checkout SSH keys" and then click the button to "Add user key." If you don't do this, it will give you an error that the key is read only.


### Step 5. Connect to CircleCI

If you do not already have a Circle CI account, head [here](https://circleci.com/signup/) and create one, and
add your project to your Circle CI account.  Here are [instructions](https://circleci.com/docs/getting-started/) if you've never done this before.

Once you have an account, if you navigate to the main [app page](https://circleci.com/dashboard/)
you should be able to click "Add Projects" and then select your
repository. If you don't see it on the list, then select a different
organization in the top left. Once you find the repository, you can
click the button to "Start Building" adn accept the defaults.

Before you push or trigger a build, let's set up the following
environment variables. Also in the project interface on CirleCi, click
the gears icon next to the project name to get to your project settings.
Under settings, click on the "Environment Variables" tab. In this
section, you want to define the following:

 *  `GITHUB_USER` and `GITHUB_EMAIL` should be your machine user Github account

### Step 6. Push and Deploy!

Once the environment variables are set up, you can push or issue a pull
request to see circle build the workflow. Remember that you only need
the `.circleci/config.yml`, `.circleci/template.html` and not any other files in the repository. If
your notebook is hosted in the same repo, you might want to add these,
along with your requirements.txt, etc.

## FAQ

**How do I customize the build or template?**

The circle configuration file is the entire workflow that does build, test, and deploy.
This literally means you can edit this text file and change any or all behavior. This could
be as simple as changing some of the text output, to adding an additional set of testing or
deployment options, or more complex like adding entire new steps in the workflow. The template.html
is the same! You can tweak it, completely change it, or throw it out and push something entirely
different back to Github pages. This deployment is open and completely transparent, as it should be.

**How do I run builds for pull requests?**

By default, new builds on CircleCI will not build for pull requests and
you can change this default in the settings. You can easily add filters
(or other criteria and actions) to be performed during or after the
build by editing the `.circleci/config.yml` file in your repository.


## Development

Build the container

```
docker build -t openbases/whedon .
```
