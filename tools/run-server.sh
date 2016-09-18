#!/bin/sh

# Make sure the directory for individual app logs exists
# mkdir -p /var/log/shiny-server
# chown shiny.shiny /var/log/shiny-server

echo "Starting up server"
exec shiny-server >> /var/log/shiny-server/shiny-server.log 2>&1
# exec shiny-server --verbose
