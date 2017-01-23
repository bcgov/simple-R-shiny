#!/bin/sh
# --------------------------------------------------------
#
# This script both builds and runs the local R-Shiny app
# using the docker file supplied.
#
# --------------------------------------------------------

# --------------------------------------------------------
#
# create the local dockerfile
#
# --------------------------------------------------------
if [[ $(diff packages.txt .packages.txt) ]] || [[ $(diff system-libraries.txt .system-libraries.txt) ]] || [[ ! -f Dockerfile.local ]]
then

  if [[ $(head -n 1 packages.txt | wc -w) -gt 0 ]]
  then
    rlib_str="$(head -n 1 packages.txt)"
  else
    rlib_str=""
  fi

  if [[ $(head -n 1 system-libraries.txt | wc -w) -gt 0 ]]
  then
    syslib_str="$(head -n 1 system-libraries.txt)"
  else
    syslib_str=""
  fi

  sed -e "s/\${RLIBS}/$rlib_str/; s/\${SYSLIBS}/$syslib_str/"  Dockerfile > Dockerfile.local

fi
cp packages.txt .packages.txt
cp system-libraries.txt .system-libraries.txt

# --------------------------------------------------------
#
# Build
#
# --------------------------------------------------------
docker build --no-cache -t shinylands -f Dockerfile.local .

# --------------------------------------------------------
#
# Run
#
# --------------------------------------------------------

os=$OSTYPE
if [[ "$os" == 'msys' ]] || [[ "$os" == 'cygwin' ]] || [[ "$os" == 'win32' ]]
then
 echo "Running on Windows"
  # --------------------------------------------------------
  #
  # Run the image - unfortunately won't mount the logs and
  # bookmarks locally
  #
  # --------------------------------------------------------
  docker run -i -t --rm --name shiny -p 3838:3838 shinylands

else
  # --------------------------------------------------------
  #
  # this runs the image and mounts everything interesting
  # to your local repo so you can play and see the logs
  # without having to go into the container (hopefully)
  #
  # --------------------------------------------------------
  docker run --rm --name shiny \
  	-p 3838:3838 \
  	-v `pwd`/_mount/bookmarks:/var/lib/shiny-server \
  	-v `pwd`/_mount/logs:/var/log/shiny-server \
  	-v `pwd`/_mount/output:/srv/shiny-server-output \
  	-v `pwd`/_mount/tmp:/tmp \
  	-v `pwd`/app:/srv/shiny-server \
  	shinylands

  # docker run --rm --name shiny \
  # 	-p 3838:3838 \
  # 	-v `pwd`/_mount/bookmarks:/var/lib/shiny-server \
  # 	-v `pwd`/_mount/logs:/var/log/shiny-server \
  # 	-v `pwd`/_mount/output:/srv/shiny-server-output \
  # 	-v `pwd`/_mount/tmp:/tmp \
  # 	-v `pwd`/app:/srv/shiny-server \
  # 	-ti --rm myshiny bash

  # docker run --rm --name shiny -p 3838:3838 -v `pwd`/_mount/bookmarks:/var/lib/shiny-server -v `pwd`/_mount/logs:/var/log/shiny-server -v `pwd`/_mount/output:/srv/shiny-server-output -v `pwd`/_mount/tmp:/tmp -v `pwd`/app:/srv/shiny-server -ti --rm myshiny bash

fi
