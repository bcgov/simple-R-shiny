#!/bin/sh
# --------------------------------------------------------
#
# This script both builds and runs the local R-Shiny app
# using the docker file supplied.
#
# --------------------------------------------------------

if [[ "$1" == "--help" ]]
then
  echo "
  Builds and deploys the app locally in a Docker image.
  If you are on a Unix-based OS (e.g., OSX or Linux) the
  logs and bookmarks will be mounted locally to help
  with debugging etc.

  Options:
    --help :     displays this message
    --no-cache : builds the Docker image from scratch,
                 ignoring the cache
                 (runs docker build with the --no-cache flag)
  "
  exit

elif [[ "$1" == "--no-cache" ]]
then
  echo "Building with no cache"
  no_cache="--no-cache"
else
  no_cache=""
fi

# --------------------------------------------------------
#
# create the local dockerfile
#
# --------------------------------------------------------
if [[ $(diff packages.txt .packages.txt) ]] || [[ $(diff gh-packages.txt .gh-packages.txt) ]] || [[ $(diff system-libraries.txt .system-libraries.txt) ]] || [[ ! -f Dockerfile.local ]]
then

  if [[ $(head -n 1 packages.txt | wc -w) -gt 0 ]]
  then
    rlib_str="$(head -n 1 packages.txt)"
  else
    rlib_str=""
  fi

  if [[ $(head -n 1 gh-packages.txt | wc -w) -gt 0 ]]
  then
  ## '@', '.', and '/' need to be escaped:
    r_gh_lib_str=$(sed 's/[\@\./]/\\&/g' <<<"$(head -n 1 gh-packages.txt)")
  else
    r_gh_lib_str=""
  fi

  if [[ $(head -n 1 system-libraries.txt | wc -w) -gt 0 ]]
  then
    syslib_str="$(head -n 1 system-libraries.txt)"
  else
    syslib_str=""
  fi

  sed -e "s/\${RLIBS}/$rlib_str/; s/\${RGHLIBS}/$r_gh_lib_str/; s/\${SYSLIBS}/$syslib_str/"  Dockerfile > Dockerfile.local

fi
cp packages.txt .packages.txt
cp gh-packages.txt .gh-packages.txt
cp system-libraries.txt .system-libraries.txt

# --------------------------------------------------------
#
# Build
#
# --------------------------------------------------------
docker build $no_cache -t shiny -f Dockerfile.local .

# --------------------------------------------------------
#
# Run
#
# --------------------------------------------------------
if [[ $? > 0 ]]
then
  echo "There was an error building the image"
  exit 1
else
  echo "Running Shiny App..."
  os=$OSTYPE
  if [[ "$os" == 'msys' ]] || [[ "$os" == 'cygwin' ]] || [[ "$os" == 'win32' ]]
  then
    # --------------------------------------------------------
    #
    # Run the image - unfortunately won't mount the logs and
    # bookmarks locally
    #
    # --------------------------------------------------------
    docker run -i -t --rm --name myshiny -p 3838:3838 shiny

  else
    # --------------------------------------------------------
    #
    # this runs the image and mounts everything interesting
    # to your local repo so you can play and see the logs
    # without having to go into the container (hopefully)
    #
    # --------------------------------------------------------
    docker run --rm --name myshiny \
      -p 3838:3838 \
      -v `pwd`/_mount/bookmarks:/var/lib/shiny-server \
      -v `pwd`/_mount/logs:/var/log/shiny-server \
      -v `pwd`/_mount/output:/srv/shiny-server-output \
      -v `pwd`/_mount/tmp:/tmp \
      -v `pwd`/app:/srv/shiny-server \
      shiny

    # docker run --rm --name shiny \
    #   -p 3838:3838 \
    #   -v `pwd`/_mount/bookmarks:/var/lib/shiny-server \
    #   -v `pwd`/_mount/logs:/var/log/shiny-server \
    #   -v `pwd`/_mount/output:/srv/shiny-server-output \
    #   -v `pwd`/_mount/tmp:/tmp \
    #   -v `pwd`/app:/srv/shiny-server \
    #   -ti --rm myshiny bash

    # docker run --rm --name shiny -p 3838:3838 -v `pwd`/_mount/bookmarks:/var/lib/shiny-server -v `pwd`/_mount/logs:/var/log/shiny-server -v `pwd`/_mount/output:/srv/shiny-server-output -v `pwd`/_mount/tmp:/tmp -v `pwd`/app:/srv/shiny-server -ti --rm myshiny bash

  fi
  exit 0
fi
