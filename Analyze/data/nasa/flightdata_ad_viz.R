#This should be pretty close.
setwd("~/apps/trelliscope/data/nasa")
library(datadr)
library(trelliscope)
library(lattice)
library(reshape2)
library(dplyr)

#load('668200205300414.RData')
fan<-df[, c(
        'N1.1-FAN_SPEED_1_LSP',
        'N1.2-FAN_SPEED_2_LSP',
        'N1.3-FAN_SPEED_3_LSP',
        'N1.4-FAN_SPEED_4_LSP')
        ]
fan<-fan %>%
        mutate(sequence=1:nrow(fan))
fan<-melt(fan, id='sequence')
fan$variable<-as.factor(fan$variable)
sample.rate <- 0.01
sub <- fan[sample(nrow(fan), size = nrow(fan)* sample.rate) , ]
sub <- sub[order(sub$variable, sub$sequence) , ]

vdbConn("vdb", autoYes = TRUE, verbose = TRUE)
bareBonesPanel <- function(x) {
        xyplot(value~sequence, data=x, type='l')
}

byEngine <- divide(sub, by = c("variable"))
makeDisplay(byEngine,
            panelFn = bareBonesPanel,
            name    = "Fan_Speed",
            desc    = "Flight 688")

library(shiny)
runApp("../../inst/trelliscopeViewerAlacer", launch.browser=TRUE)