# --------------------------------------------------------
#
# Start with the basic r image
#
# --------------------------------------------------------
FROM r-base:latest

# --------------------------------------------------------
#
# Install all the pre-reqs
#
# --------------------------------------------------------
RUN apt-get update && apt-get install -y -t unstable \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev
# --------------------------------------------------------
#
# Download and install shiny server
#
# --------------------------------------------------------
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')"
# --------------------------------------------------------
#
# put this back in to copy over the examples for testing purposes
#
# --------------------------------------------------------
#    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

# --------------------------------------------------------
#
# An environment varialbe called RLIBS is expected to be
# present in order to install the correct r libraries.
# this can be slow for building, so comment this out
# during dev and explicitly load the packages as per the
# example
#
# --------------------------------------------------------
# ENV RLIBS "'ggplot2'"
RUN R -e "install.packages( ${RLIBS} )"
# RUN R -e "install.packages( 'ggplot2' )"

# --------------------------------------------------------
#
# expose the 3838 port
#
# --------------------------------------------------------
EXPOSE 3838

# --------------------------------------------------------
#
# copy over your application and the supporting files in
# the data and www directory
#
# --------------------------------------------------------
COPY app/app.R /srv/shiny-server/
COPY app/data /srv/shiny-server/data
COPY app/www /srv/shiny-server/www

# --------------------------------------------------------
#
# copy over the startup script
#
# --------------------------------------------------------
COPY tools/run-server.sh /usr/bin/shiny-server.sh

# --------------------------------------------------------
#
# run the startup script
#
# --------------------------------------------------------
CMD ["/usr/bin/shiny-server.sh"]
