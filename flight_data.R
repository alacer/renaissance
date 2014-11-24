setwd("/Users/Live/repos/trelliscope")

# install.packages("devtools") 
# install_github("tesseradata/datadr")
# install_github("tesseradata/trelliscope")
library(devtools)
library(datadr)
library(trelliscope)
library(lattice)
library(reshape2)
library(dplyr)
library(shiny)


load('668200205300414.RData')

fan<-df[, c(
    'N1.1-FAN_SPEED_1_LSP',
    'N1.2-FAN_SPEED_2_LSP',
    'N1.3-FAN_SPEED_3_LSP',
    'N1.4-FAN_SPEED_4_LSP')
    ]

fan$sequence <-1:nrow(fan)
fan<-melt(fan, id='sequence')
fan$variable<-as.factor(fan$variable)


numwindows <- 4
windowsize <- max(fan$sequence)/numwindows
fan$window <- 1
for (i in 1:numwindows) {
    fan[fan$sequence > i*windowsize, "window"] <- i+1
}
fan$window <- as.factor(fan$window)


sample.rate <- 0.1
sub <- fan[sample(nrow(fan), size = nrow(fan)* sample.rate) , ]
sub <- sub[order(sub$variable, sub$sequence) , ]

vdbConn("vdb", name="flightdata", autoYes = TRUE)

bareBonesPanel <- function(x) {
    xyplot(value~sequence, data=x, type='l')
}

byEngine <- divide(sub, by = c("variable", "window"))

makeDisplay(byEngine,
            panelFn = bareBonesPanel,
            name    = "FanSpeed",
            desc    = "Flight 688")

runApp('./inst/trelliscopeViewerAlacer', launch.browser=TRUE)
