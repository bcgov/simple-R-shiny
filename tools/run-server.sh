#!/bin/sh
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

me=`whoami`
directory=/etc/shiny-server
configuration=shiny-server.conf
temp=shiny-server.conf.tmp

# echo 'running as'
# echo $me

# sed -e "s/^run_as .*;$/run_as $me;/"  $directory/$configuration > $directory/$temp
# mv $directory/$temp $directory/$configuration

shiny-server
