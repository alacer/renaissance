#
# install shinyapps
#
if (!require("devtools"))
        install.packages("devtools")
devtools::install_github("rstudio/shinyapps")

#
# authorize for Alacer shiny apps
#
shinyapps::setAccountInfo(
        name="alacer", 
        token="E8A07EBF94AB95D4F0DBB60B2E553C2D", 
        secret="UrtQmkOXJEeGUVpTo55HT/hlvj5ewGGCuC7QGqJA")

#
# deploy
#
#
# set directory where UI.R lives
#

setwd("~/apps/trelliscope/data/worldbank")
library(shinyapps)
library(shiny)
library(datadr)
library(trelliscope)
library(rCharts)
deployApp(account="alacer", application="worldbank")
# runApp("../../inst/trelliscopeViewerAlacer", launch.browser=TRUE)

#
# debug
#
shinyapps::showLogs(account="alacer", appName="worldbank")
