#!/bin/sh
me=`whoami`
directory=/etc/shiny-server
configuration=shiny-server.conf
temp=shiny-server.conf.tmp

echo 'running as'
echo $me

sed -e "s/^run_as .*;$/run_as $me;/"  $directory/$configuration > $directory/$temp
mv $directory/$temp $directory/$configuration

shiny-server
