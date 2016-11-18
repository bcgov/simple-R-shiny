# Shiny Server Development Template

## Introduction

This repo is intended to be forked and used as a development repo for R applications that use [Shiny](http://shiny.rstudio.com/) as a visualization server.  The code is designed
to run locally in development using Docker, and can be productionized using your github repo through OpenShift.

### Where do I put my code?

All of your code goes into the app directory. Data goes into the app/data directory and web resources such as css and images go into app/www directory.
If you have a README for your project, please also put it here.  Your Shiny code can go into one file as per the example, or you can split it into
seperate ui and server files as you wish.

## Getting Started

There are several steps you must complete in order to begin:

### 1. Install Docker

Instructions for installing docker on your local OS are [provided here](https://docs.docker.com/engine/installation/ "Yeah! Install Docker").

### 2. Fork this repo

This repo is already set up to work with Docker and Openshift, so it is simplest to fork this repo into your own, and thereby take advatage of any future changes to the tools provided.
Instructions for forking into your own github repo are [provided here](https://help.github.com/articles/fork-a-repo/ "Fork Repo in Github").

### 3. Clone to your machine

You now need to clone the new repo onto your local machine so that you can start entering your code and developing.  There are many graphical tools available that can help manage this,
some of which can be found [here](https://git-scm.com/download/gui/linux "Github GUI").  Or you can simply use the command line, instructions for which can be
found [here](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository "git command line").

### 4. Edit the packages.txt file

The packages.txt file contains an array of strings that indicate the packages you will be using in your R program.  This list is used when building your local Dockerfile so that the
build process runs as fast as possible.  If you are familiar with Docker you know that you can also set environment variables that import this information, however this prevents the build process
from using the cached layer for this step.  Therefore the packages.txt file is used to build an explicit local Dockerfile that ensures fast repeated builds.

The packages.txt file should look something like this:
```
'package1', 'package2', 'package3'
```
with all packages on the same line.

Do not include 'shiny' or 'rmarkdown' in packages.txt as they are installed automatically.

### 5. Edit the system-libraries.txt file

If any of the R packages you need to install require special system libraries (to be installed with `apt-get install`; eg. `libgdal-dev` and `libproj-dev` for the [`rgdal`](https://cran.rstudio.com/web/packages/rgdal/) package, or `libxml2-dev` for the [`xml2`](https://cran.rstudio.com/web/packages/xml2/) package), list them in this file. It works similarly to packages.txt to build an explicit local Dockerfile that ensures fast repeated builds.

The system-libraries.txt should look something like this (libraries separated by a space, no quotation marks):
```
lib1 lib2
```

### 6. Run / Develop

With all your packages listed in the packages.txt file, and your code in the app directory you should be able to run `./dev.sh` at the command line in the root of your project to initiate Docker.
```
$ ./dev.sh
```
This command will build a local Dockerfile and run it for you.  All of your code will be added to the container and run.  Especially important is that new directories
will appear in the root of your project under the '_mount' directory:

- **_mount/bookmarks** : This is where shiny will write its bookmarks
- **_mount/logs**      : Pretty much what you  might expect
- **_mount/output**    : In your program, if you write to '/srv/shiny-server-output' it will show up here
- **_mount/tmp**       : The /tmp directory if you need to debug the temporary files created by shiny

**Note: If you are on Windows and using Docker with VirtualBox**, use the `dev-win.sh` file instead of `dev.sh` - It unfortunately won't be able to mount the logs and bookmarks folders locally, but it will build and lanch the app.

The first time you run dev.sh you will see a lot of output where docker is building the container image for the first time and installing all the dependancies.
On each successive run as you modify your code and run dev.sh, you will see that only your new code gets placed into the image and run.  If you add new packages
*do not forget to update the packages.txt file* or you will see the missing packages errors in your R program logs.
