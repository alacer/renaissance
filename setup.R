#
# trelliscope
#

setwd("~/apps/trelliscope")
library(shiny)
runApp("inst/trelliscopeViewerAlacer", launch.browser=TRUE)

# install packages (one time only)
install.packages("devtools") # if not installed
devtools::install_github("tesseradata/datadr")
devtools::install_github("tesseradata/trelliscope")

