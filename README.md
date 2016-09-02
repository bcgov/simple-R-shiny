## Simple shiny app to test Shiny Server on openshift

This is a basic shiny app that ensures the server is set up properly to allow a shiny app to read local files (an image file, a CSS file, and a CSV file) and to write to local disk.

Every time you click on "Write data to shiny server disk (csv)", a new CSV file will be created in the root of this repository.

You need to install the `ggplot2` package for the app to work (`install.packages("ggplot2")`).

Instructions on how to set up Shiny Server on Ubuntu: http://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/

