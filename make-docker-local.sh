#!/bin/sh

# --------------------------------------------------------
#
# create the local dockerfile
#
# --------------------------------------------------------
if [[ $(diff packages.txt .packages.txt) ]] || [[ $(diff system-libraries.txt .system-libraries.txt) ]] || [[ ! -f Dockerfile.local ]]
then

  if [[ $(head -n 1 packages.txt | wc -w) -gt 0 ]]
  then
    rlib_str="RUN R -e \"install.packages(c( $(head -n 1 packages.txt) ))\""
  else
    rlib_str=""
  fi

  if [[ $(head -n 1 system-libraries.txt | wc -w) -gt 0 ]]
  then
    syslib_str="RUN apt-get update \&\& apt-get install -y -t unstable $(head -n 1 system-libraries.txt)"
  else
    syslib_str=""
  fi

  sed -e "s/\${RLIBS}/$rlib_str/; s/\${SYSLIBS}/$syslib_str/"  Dockerfile > Dockerfile.local

fi
cp packages.txt .packages.txt
cp system-libraries.txt .system-libraries.txt
