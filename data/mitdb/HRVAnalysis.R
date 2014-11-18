

library(RHRV)
setwd("c:/users/kristan/dropbox/alacerprojects/hrv/")
hrv.wfdb = CreateHRVData()
hrv.wfdb = SetVerbose(hrv.wfdb, TRUE)
hrv.wfdb = LoadBeatWFDB(hrv.wfdb, "3100331", RecordPath ="3100331/", annotator = "qrs")
hrv.data = BuildNIHR(hrv.wfdb)
range(hrv.data$Beat$niHR)
hrv.data$Beat$niHR[!is.finite(hrv.data$Beat$niHR)] <- NA
hrv.data$Beat <- na.omit(hrv.data$Beat)
hrv.data = FilterNIHR(hrv.data)
PlotNIHR(hrv.data)