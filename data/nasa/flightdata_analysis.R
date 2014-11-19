
#
# try loading some data from AWS
#
# install.packages("AWS.tools")
# 
# library(AWS.tools)
# s3.get(bucket, bucket.location = "US", verbose = FALSE, debug = FALSE)

setwd("~/apps/trelliscope/data/nasa")

#
# load some data locally
#

setwd("~/Downloads/nasa_flt3")
data <- read.csv("200205190652.csv", header=TRUE, stringsAsFactor=FALSE)

#
# Remove non-categorical by counting unique values for each column and filtering out those with <25 unique values
#
counted.vals <- sapply(data, function(x) length(unique((x))))
noncat <- data[,as.logical(counted.vals>25)]

#
# Run PCA 
#
quartz()
pca <- princomp(noncat)
biplot(pca)

library(datadr)
library(trelliscope)

vdbConn("vdb", name="flightdata", autoYes = TRUE)

bareBonesPanel <- function(x) 
        plot(row.names(data), data$EGT.1.EXHAUST_GAS_TEMPERATURE_1, type="l")

byEvent <- divide(data, by = c("EVNT.EVENT_MARKER"))

makeDisplay(byEvent,
            panelFn = bareBonesPanel,
            name    = "Fan_speed_vs_Temp",
            desc    = "Flight 3")

library(shiny)
runApp("../../inst/trelliscopeViewerAlacer", launch.browser=TRUE)



