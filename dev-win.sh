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
	sed -e "s/\${RLIBS}/$(head -n 1 packages.txt)/"  Dockerfile > Dockerfile.local
fi
cp packages.txt .packages.txt

# --------------------------------------------------------
#
# Build
#
# --------------------------------------------------------
docker build -t myshiny -f Dockerfile.local .

# --------------------------------------------------------
#
# Run the image - unfortunately won't mount the logs and
# bookmarks locally
#
# --------------------------------------------------------
docker run -i -t --rm --name shiny -p 3838:3838 myshiny
