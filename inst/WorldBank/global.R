
setwd("~/trelliscope/inst/worldbank")
load("allcountryrisk.RData")

library(shiny)
library(datadr); library(trelliscope)
library(rCharts)

byCountry <- divide(allcountryrisk, by = c("country"), update = TRUE)

vdbConn("WorldBank/vdb", autoYes = TRUE)
CogFunctions <- function(x) {list(
  meanDemocracy = cogMean(x$levelDemocracy),
  RangeDemocracy = cogRange(x$levelDemocracy),
  meanwarPast5Years = cogMean(x$warPast5Years),
  RangewarPast5Years = cogRange(x$warPast5Years),
  meanwarThisYear = cogMean(x$warThisYear),
  RangewarThisYear = cogRange(x$warThisYear),
  meanCreditDepositsRatio = cogMean(x$CreditDepositsRatio),
  RangeCreditDepositsRatio = cogRange(x$CreditDepositsRatio),
  meanZscore = cogMean(x$Zscore),
  RangeZscore = cogRange(x$Zscore),
  meanLiquidAssetsDepositsSTFRatio = cogMean(x$LiquidAssetsDepositsSTFRatio),
  RangeLiquidAssetsDepositsSTFRatio = cogRange(x$LiquidAssetsDepositsSTFRatio),
  meanCostIncomeRatio = cogMean(x$CostIncomeRatio),
  RangeCostIncomeRatio = cogRange(x$CostIncomeRatio),
  meanStrengthLegalRights = cogMean(x$StrengthLegalRights),
  RangeStrengthLegalRights = cogRange(x$StrengthLegalRights),        
  nObs = cog(sum(!is.na(x$year)), 
             desc = "number of years for recorded data")
)}
CogFunctions(byCountry[[1]][[2]])

# make and test panel function

timePanelhc <- function(x){
  hp <- hPlot(risk ~ year, data = x, type='line', group="model", radius=0)
  hp
}
timePanelhc(byCountry[[1]][[2]])

# add display panel and cog function to vdb
makeDisplay(byCountry,
            name = "Country_Risk_HighCharts_v2",
            desc = "Country-Level Risk Ratings By Year, Testing Two Models",
            panelFn = timePanelhc, cogFn = CogFunctions,
            width = 400, height = 400)
#runApp("../../inst/trelliscopeViewerAlacer", 
#  launch.browser=TRUE)





