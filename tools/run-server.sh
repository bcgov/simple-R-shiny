#!/bin/sh

exec shiny-server >> /var/log/shiny-server/shiny-server.log 2>&1
# exec shiny-server --verbose
