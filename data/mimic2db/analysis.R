library(RHRV)
setwd("c:/users/kristan/dropbox/mimic2db")
hrv.data = CreateHRVData()
hrv.data = SetVerbose(hrv.data, TRUE)
hrv.data = LoadBeatWFDB(hrv.data, "a40024", RecordPath ="a40024/", annotator = "qrs")
hrv.data = BuildNIHR(hrv.data)
PlotNIHR(hrv.data)
range(hrv.data$Beat$niHR)
hrv.data$Beat$niHR[!is.finite(hrv.data$Beat$niHR)] <- 300
PlotNIHR(hrv.data)
hrv.data = FilterNIHR(hrv.data)
hrv.data=InterpolateNIHR (hrv.data, freqhr = 4)
PlotHR(hrv.data)
hrv.data = CreateTimeAnalysis(hrv.data,size=300,interval = 7.8125)
HRData <- data.frame(hrv.data$HR ,1)
names(HRData)[2] <- "Segment"
Segments <- rep(c(1:ceiling(nrow(HRData)/7200)), each=7200)
HRData$Segment <- Segments[1:length(HRData$Segment)]
