#!/bin/sh
# --------------------------------------------------------
#
# This script both builds and runs the local R-Shiny app
# using the docker file supplied.
#
# --------------------------------------------------------

# --------------------------------------------------------
#
# Build
#
# --------------------------------------------------------
docker build -t myshiny .

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
	-v `pwd`/app:/srv/shiny-server \
	myshiny


	# -v `pwd`/_mount/tmp:/tmp \
