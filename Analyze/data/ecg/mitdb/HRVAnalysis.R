

library(RHRV)
setwd("c:/users/kristan/documents/github/trelliscope/data/mitdb")
hrv.wfdb = CreateHRVData()
hrv.wfdb = SetVerbose(hrv.wfdb, TRUE)
hrv.wfdb = LoadBeatWFDB(hrv.wfdb, "203", RecordPath ="203/", annotator = "qrs")
hrv.data = BuildNIHR(hrv.wfdb)
PlotNIHR(hrv.data)

hrv.data=InterpolateNIHR (hrv.data, freqhr = 4)
PlotHR(hrv.data)
hrv.data = CreateTimeAnalysis(hrv.data, size = 300, interval = 7.8125)
hrv.data = CreateFreqAnalysis(hrv.data)
hrv.data = CalculatePowerBand(hrv.data, indexFreqAnalysis= 1, size = 300, shift = 30, sizesp = 2048, type = "fourier",ULFmin = 0, ULFmax = 0.03, VLFmin = 0.03, VLFmax = 0.05,LFmin = 0.05, LFmax = 0.15, HFmin = 0.15, HFmax = 0.4)
PlotPowerBand(hrv.data, indexFreqAnalysis = 1, ymax = 400, ymaxratio = 1.7)

hrv.data = CreateFreqAnalysis(hrv.data)
hrv.data = CalculatePowerBand( hrv.data , indexFreqAnalysis= 2,type = "wavelet", wavelet = "la8", bandtolerance = 0.01, relative = FALSE,ULFmin = 0, ULFmax = 0.03, VLFmin = 0.03, VLFmax = 0.05, LFmin = 0.05, LFmax = 0.15, HFmin = 0.15, HFmax = 0.4 )
PlotPowerBand(hrv.data, indexFreqAnalysis = 2, ymax = 700, ymaxratio = 50)

hrv.data <- CreateNonLinearAnalysis(hrv.data)
hrv.data <- NonlinearityTests(hrv.data)
hrv.data = SurrogateTest(hrv.data, significance = 0.05, useFunction = timeReversibility, tau=4, doPlot = TRUE)


kTimeLag = CalculateTimeLag(hrv.data,lagMax=100, doPlot=FALSE)
kEmbeddingDim = CalculateEmbeddingDim(hrv.data, numberPoints = 10000, timeLag = kTimeLag,maxEmbeddingDim = 15)
my.index = 1
hrv.data = CalculateCorrDim(hrv.data, indexNonLinearAnalysis = my.index, minEmbeddingDim = kEmbeddingDim - 1, maxEmbeddingDim = kEmbeddingDim + 2, timeLag = kTimeLag, minRadius=1, maxRadius=100, pointsRadius = 100, theilerWindow = 20, doPlot = FALSE)

corr.struct = hrv.data$NonLinearAnalysis[[my.index]]$correlation

corrSum = corr.struct$computations

print(corrSum$corr.matrix[1:4,1:4])
