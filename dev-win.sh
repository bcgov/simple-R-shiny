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
if [[ $(diff packages.txt .packages.txt) ]] || [[ ! -f Dockerfile.local ]]
then
  if [[ $(head -n 1 packages.txt | wc -w) -gt 0 ]]
  then
  	sed -e "s/\${RLIBS}/RUN R -e \"install.packages(c( $(head -n 1 packages.txt) ))\"/"  Dockerfile > Dockerfile.local
  else
    sed -e "s/\${RLIBS}//"  Dockerfile > Dockerfile.local
  fi
fi
cp packages.txt .packages.txt

# --------------------------------------------------------
#
# Build
#
# --------------------------------------------------------
# docker build -t myshiny -f Dockerfile.local .

# --------------------------------------------------------
#
# Run the image - unfortunately won't mount the logs and
# bookmarks locally
#
# --------------------------------------------------------
# docker run -i -t --rm --name shiny -p 3838:3838 myshiny
