

setwd("c:/users/kristan/documents/github/trelliscope/data/mimic2db")

load("nonactionabledata.RData")

library(shiny)
library(datadr); library(trelliscope)
library(reshape2)

library(rCharts)


naa <- aggregate(nonactionable$alarm, by=list(nonactionable$id, 
  nonactionable$DayHour, nonactionable$Aux.x), sum)
names(naa) <- c("Patient", "Hour", "Alarm", "Number")
naa$Alarm <- as.character(naa$Alarm)

byPatientHour <- divide(naa, by = c("Patient", "Hour"), update = TRUE)


vdbConn("MIMIC2DBGraphs/vdb", autoYes = TRUE)
alarmCog <- function(x) {list(
  TotalAlarms = cog(sum(!is.na(x$Number)), 
             desc = "Number of Alarm readings")
)}
alarmCog(byPatientHour[[1]][[2]])

##############
#with upper and lower bounds
# make and test panel function
barPanel <- function(x){
  barchart(Alarm ~ Number, data=x, col="darkred", xlab="Number of Alarms")
}
barPanel(byPatientHour[[1]][[2]])

# add display panel and cog function to vdb
makeDisplay(byPatientHour,
            name = "Alarms_PerHour",
            desc = "Alarm Summary Per Patient Per Hour",
            panelFn = barPanel, cogFn = alarmCog,
            width = 400, height = 400)


# view the display
library(shiny)
runApp("../../inst/trelliscopeViewerAlacer", launch.browser=TRUE)
