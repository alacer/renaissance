
###set working directory and read in mitdb data record 100
setwd("c:/users/kristan/documents/github/trelliscope/data/mitdb")
r100 <- read.csv("100/100.csv", stringsAsFactors=FALSE, quote="'", header=FALSE, skip=2)
names(r100) <- c("ElapsedTime", "MLII", "V5")

head(r100)

a100 <- read.fwf("100/100ann.txt", stringsAsFactors=FALSE, header=FALSE, widths=c(12,9,7,5,5,4), col.names=c("ElapsedTime", "Sample", "Type", "Sub", "Chan", "Num"), strip.white=TRUE)
a100 <- a100[-1,]
head(a100)


r100$ETime <- strptime(r100$ElapsedTime, format="%M:%OS")
op <- options(digits.secs=3)
head(r100)

r100$Minutes <- as.numeric(format(r100$ETime, "%M"))
r100$Seconds <- as.numeric(format(r100$ETime, "%OS"))+(r100$Minutes*60)
r100$TenSecond <- floor(r100$Seconds/10)

r100$AnnotationTime <- NA
tmp <- as.numeric(a100$Sample)
r100$AnnotationTime[tmp] <- a100$ElapsedTime
r100$AnnotationType <- NA
r100$AnnotationType[tmp] <- a100$Type
r100$AnnotationSub <- NA
r100$AnnotationSub[tmp] <- a100$Sub
r100$AnnotationChan <- NA
r100$AnnotationChan[tmp] <- a100$Chan
r100$AnnotationNum <- NA
r100$AnnotationNum[tmp] <- a100$Num

###############
library(datadr); library(trelliscope)
r100$TenSecond <- as.factor(r100$TenSecond)
r100 <- r100[,-4]
byMin <- divide(r100, by = c("TenSecond"), update = TRUE)

vdbConn("MITDBGraphs/vdb", autoYes = TRUE)
heartCog <- function(x) { list(
  meanMLII = cogMean(x$MLII),
  RangeMLII = cogRange(x$MLII),
  nObs = cog(sum(!is.na(x$MLII)), 
             desc = "number of sensor readings"),
  meanV5 = cogMean(x$V5),
  RangeV5 = cogRange(x$V5)
)}
heartCog(byMin[[1]][[2]])

# make and test panel function
timePanel <- function(x)
  xyplot(MLII + V5 ~ Seconds,
         data = x, auto.key = TRUE, type="l")
timePanel(byMin[[1]][[2]])

############################################
#############################################
############################################

#still working on these code pieces!

library(rCharts)
timePanelhc <- function(x){
  hp <- hPlot(MLII ~ Seconds, data = x, type='line', radius=0)
  hp$series(data=list())
  hp$colors(c("darkblue"))
  hp
}
timePanelhc(byMin[[1]][[2]])


# add display panel and cog function to vdb
makeDisplay(byMin,
            name = "ecg_by_ten_sec_interval",
            desc = "ECG Readings Viewed Per 10 Second Intervals",
            panelFn = timePanel, cogFn = priceCog,
            width = 400, height = 400,
            lims = list(x = "same"))

# view the display
library(shiny)
runApp("trelliscopeViewerAlacer", launch.browser=TRUE)

timePanel <- function(x)
  xyplot(medListPriceSqft + medSoldPriceSqft ~ time,
         data = x, auto.key = TRUE, ylab = "$ / Sq. Ft.")
timePanel(byCounty[[1]][[2]])
timePanel <- function(x)
  xyplot(medListPriceSqft + medSoldPriceSqft ~ time,
         data = x, auto.key = TRUE, ylab = "$ / Sq. Ft.")
timePanel(byCounty[[1]][[2]])

