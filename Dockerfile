# -----------------------------------------
#
# start with basic debian
#
# -----------------------------------------
FROM debian:testing
ADD tools/rootfs.tar.xz /

# -----------------------------------------
#
# FROM R-BASE
#
# -----------------------------------------
RUN useradd docker \
    && mkdir /home/docker \
    && chown docker:docker /home/docker \
    && addgroup docker staff

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ed \
        less \
        locales \
        vim-tiny \
        wget \
        ca-certificates \
        procps \
    && rm -rf /var/lib/apt/lists/*

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Use Debian unstable via pinning -- new style via APT::Default-Release
RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
    && echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default

ENV R_BASE_VERSION 3.4.1

## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
RUN apt-get update \
    && apt-get install -t unstable -y --no-install-recommends \
        littler \
        r-cran-littler \
        r-base=${R_BASE_VERSION}* \
        r-base-dev=${R_BASE_VERSION}* \
        r-recommended=${R_BASE_VERSION}* \
        && echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
        && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && install.r docopt \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------
#
# Install all the pre-reqs (and optional supplied in system-libraries.txt)
#
# --------------------------------------------------------
ENV SYS_LIBS "${SYSLIBS}"
RUN apt-get update && apt-get install -y -t unstable \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-openssl-dev \
    libssl-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libnss-wrapper \
    gettext $SYS_LIBS


# --------------------------------------------------------
#
# Install shiny and rmarkdown
#
# --------------------------------------------------------
RUN install2.r --error shiny rmarkdown

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
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

# --------------------------------------------------------
#
# Install R packages if required
#
# --------------------------------------------------------
ENV R_LIBS "${RLIBS}"
RUN if [ "$R_LIBS" ]; \
   then \
   echo "Installing CRAN packages: '$R_LIBS'" && \
   install2.r --error $R_LIBS; \
   fi

# --------------------------------------------------------
# GitHub R packages
# --------------------------------------------------------
ENV R_GH_LIBS "${RGHLIBS}"
RUN if [ "$R_GH_LIBS" ]; \
   then \
   echo "Installing GitHub packages: '$R_GH_LIBS'" && \
   install2.r --error remotes && \
   R -e "lapply(strsplit(Sys.getenv('R_GH_LIBS'), '\\\s+')[[1]], remotes::install_github)"; \
   fi

# --------------------------------------------------------
#
# add custom configuration
#
# --------------------------------------------------------
COPY tools/shiny-server.conf /etc/shiny-server/

# --------------------------------------------------------
#
# Make and set permissions for log & bookmarks directories
#
# --------------------------------------------------------

RUN sudo mkdir -p /var/shinylogs/shiny-server && \
    mkdir -p /var/lib/shiny-server/bookmarks && \
    chown shiny:shiny /var/shinylogs/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server/bookmarks/

# --------------------------------------------------------
#
# expose the 3838 port
#
# --------------------------------------------------------
EXPOSE 3838


# --------------------------------------------------------
#
# copy over the startup script
#
# --------------------------------------------------------
COPY tools/passwd.template /passwd.template
COPY tools/run-server.sh /usr/bin/shiny-server.sh
COPY tools/run-test.sh /usr/bin/run-test.sh
RUN chmod a+x /usr/bin/shiny-server.sh
RUN chmod a+x /usr/bin/run-test.sh

# --------------------------------------------------------
#
# copy over your application and the supporting files in
# the data and www directory. This is done last because it
# is most likely to change frequently. This allows greater
# use of Docker caching as everying downstream of a change
# will invalidate the cache for those steps.
#
# --------------------------------------------------------
COPY app/ /srv/shiny-server/
RUN mkdir /srv/shiny-server/output/ && \
    chown -R shiny:shiny /srv/shiny-server/

# --------------------------------------------------------
#
# run the server
#
# -----------------------------------------
#USER shiny
#CMD ["shiny-server"]
CMD ["/usr/bin/shiny-server.sh"]
