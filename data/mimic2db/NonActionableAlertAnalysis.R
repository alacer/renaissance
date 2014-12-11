
setwd("c:/users/kristan/documents/github/trelliscope/data/mimic2db")

load("nonactionabledata.RData")
#load("alldata02.RData")
#load("alldata14.RData")

nonactionable$nalarms <- ave(nonactionable$alarm, as.factor(nonactionable$id), FUN=cumsum)

worsthour <- aggregate(nonactionable$alarm, by=list(nonactionable$DayHour), sum)
worsthour <- worsthour[order(worsthour$x, decreasing=TRUE),]

nonactionsamples <- nonactionable[nonactionable$DayHour=="14-29",c(1:2,25)]
nonactionsamples$lower <- nonactionsamples$SampleN-625
nonactionsamples$upper <- nonactionsamples$SampleN+625
nonactionsamples$lower[nonactionsamples$lower<0] <- 0
nonactionsamples$filename <- paste(nonactionsamples$id, nonactionsamples$nalarm, sep="_")
nonactionsamples <- nonactionsamples[,-3]
write.csv(nonactionsamples, file="nonactionsamples1.csv")

nonactionsamples <- nonactionable[nonactionable$DayHour=="02-02",c(1:2,25)]
nonactionsamples$lower <- nonactionsamples$SampleN-625
nonactionsamples$upper <- nonactionsamples$SampleN+625
nonactionsamples$lower[nonactionsamples$lower<0] <- 0
nonactionsamples$filename <- paste(nonactionsamples$id, nonactionsamples$nalarm, sep="_")
nonactionsamples <- nonactionsamples[,-3]
write.csv(nonactionsamples, file="nonactionsamples.csv")


library(shiny)
library(datadr); library(trelliscope)
library(reshape2)

library(rCharts)

nonactionable <- nonactionable[nonactionable$DayHour=="02-02" | nonactionable$DayHour=="14-29",]


naa <- aggregate(nonactionable$alarm, by=list(nonactionable$id, 
  nonactionable$DayHour, nonactionable$Aux.x), sum)
names(naa) <- c("Patient", "Hour", "Alarm", "Number")
naa$Alarm <- as.character(naa$Alarm)

# totalalarmsperpatienthour <- aggregate(naa$Number, by=list(naa$Patient, naa$Hour), sum)
# totalalarms02 <- totalalarmsperpatienthour[totalalarmsperpatienthour$Group.2=="02-02",]
# totalalarms02 <- totalalarms02[order(totalalarms02$x, decreasing=TRUE),]
# totalalarms14 <- totalalarmsperpatienthour[totalalarmsperpatienthour$Group.2=="14-29",]
# totalalarms14 <- totalalarms14[order(totalalarms14$x, decreasing=TRUE),]

# toppatients02 <- totalalarms02$Group.1[1:5]
# toppatients14 <- totalalarms14$Group.1[1:5]

# topwave02 <- alldata02[alldata02$Patient %in% toppatients02,]
# topwave14 <- alldata14[alldata14$Patient %in% toppatients14,]
# rm(alldata02, alldata14)

byPatientHour <- divide(naa, by = c("Patient", "Hour"), update = TRUE)

# library(parallel)
# cl <- makeCluster(3)

# byWave02 <- divide(alldata02, by=c("Patient", "Hour"), update=TRUE)
 
vdbConn("MIMIC2DBGraphs/vdb", autoYes = TRUE)
alarmCog <- function(x) {list(
  TotalAlarms = cog(sum(!is.na(x$Nudmber)), 
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

# timePanel <- function(x){
#   hp <- hPlot(Value ~ Time, group='variable', data = x, type='line', radius=0)
#   hp
# }

# makeDisplay(byWave,
#   name= "Alarms_WaveformData"
#   desc = "Waveform Segments of Alarms"
#   panelFn = timePanel
#   )


# view the display
library(shiny)
runApp("../../inst/trelliscopeViewerAlacer", launch.browser=TRUE)
