# library(RHRV)
# setwd("c:/users/kristan/documents/github/trelliscope/data/mimic2db")
# #use string with x and y:
# #ex for x: "a40024"
# #and y: "a40024/"
# hrvextract <- function(x,y){
#   hrv.data = CreateHRVData()
#   hrv.data = LoadBeatWFDB(hrv.data, x, RecordPath = y, annotator = "qrs")
#   hrv.data = BuildNIHR(hrv.data)
#   range(hrv.data$Beat$niHR)
#   hrv.data$Beat$niHR[!is.finite(hrv.data$Beat$niHR)] <- 300
#   hrv.data = FilterNIHR(hrv.data)
#   hrv.data=InterpolateNIHR (hrv.data, freqhr = 4)
#   hrv.data = CreateTimeAnalysis(hrv.data,size=300,interval = 7.8125)
#   HRData <- data.frame(hrv.data$HR ,1)
#   names(HRData) <- c("HR", "Segment")
#   Segments <- rep(c(1:ceiling(nrow(HRData)/7200)), each=7200)
#   HRData$Segment <- Segments[1:length(HRData$Segment)]
#   HRData$Shift <- ceiling(HRData$Segment/24)
#   HRData$Patient <- x
#   HRData$SegmentShiftMean <- ave(HRData$HR, HRData$Shift, HRData$Segment, FUN=mean)
#   HRData$SegmentShiftSD <- ave(HRData$HR, HRData$Shift, HRData$Segment, FUN=sd)
#   HRData$SegmentShiftlower <- HRData$SegmentShiftMean-(1.96*HRData$SegmentShiftSD)
#   HRData$SegmentShiftupper <- HRData$SegmentShiftMean+(1.96*HRData$SegmentShiftSD)
#   return(HRData)
# }
# 
# ############################################
# a40075 <- hrvextract("a40075", "a40075/")
# a40076 <- hrvextract("a40076", "a40076/")
# a40086 <- hrvextract("a40086", "a40086/")
# #a40109 <- hrvextract("a40109", "a40109/")
# a40075$Seconds <- seq(from=0, to=((nrow(a40075)-1)/4)+.2, by=.25)
# a40076$Seconds <- seq(from=0, to=((nrow(a40076)-1)/4), by=.25)
# a40086$Seconds <- seq(from=0, to=((nrow(a40086)-1)/4), by=.25)
# 
# 
# alldata <- rbind(a40075,a40076,a40086)

setwd("c:/users/kristan/documents/github/trelliscope/data/mimic2db")

load("workingdata.RData")

library(shiny)
library(datadr); library(trelliscope)
library(reshape2)

library(rCharts)
byPatientShiftSeg <- divide(alldata, by = c("Patient", "Shift", "Segment"), update = TRUE)


vdbConn("MIMIC2DBGraphs/vdb", autoYes = TRUE)
heartCog <- function(x) {list(
  meanHR = cogMean(x$HR),
  RangeHR = cogRange(x$HR),
  nObs = cog(sum(!is.na(x$HR)), 
             desc = "number of sensor readings")
)}
heartCog(byPatientShiftSeg[[1]][[2]])

# make and test panel function

timePanelhc <- function(x){
  hp <- hPlot(HR ~ Seconds, data = x, type='line', radius=0)
  hp
}
timePanelhc(byPatientShiftSeg[[1]][[2]])


# add display panel and cog function to vdb
makeDisplay(byPatientShiftSeg,
            name = "HR_Shift_30Min_Interval",
            desc = "Heart Rate Overview, 30 Minute Intervals",
            panelFn = timePanelhc, cogFn = heartCog,
            width = 400, height = 400)

##############
#with upper and lower bounds
# make and test panel function
timePanel <- function(x){
   plot(x=x$Seconds, y=x$HR, type="l", xlab="Seconds", ylab="HR")
   lines(x=x$Seconds, y=x$SegmentShiftupper, col="gold", lty=2)
   lines(x=x$Seconds, y=x$SegmentShiftlower, col="gold", lty=2)
   lines(x=x$Seconds, y=rep(30, length(x$Seconds)), col="darkred", lty=3)
   lines(x=x$Seconds, y=rep(140, length(x$Seconds)), col="darkred", lty=3)
}
timePanel(byPatientShiftSeg[[1]][[2]])

# add display panel and cog function to vdb
makeDisplay(byPatientShiftSeg,
            name = "HR_Shift_30Min_Interval_Cutoffs",
            desc = "Heart Rate Overview, 30 Minute Intervals, With Alarm Settings",
            panelFn = timePanel, cogFn = heartCog,
            width = 400, height = 400)


# view the display
library(shiny)
runApp("../../inst/trelliscopeViewerAlacer", launch.browser=TRUE)
