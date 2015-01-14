
# setwd("~/trelliscope/data/worldbank")
load("allcountryriskmelt.RData")

library(shiny)
library(datadr); library(trelliscope)
library(rCharts)

#byCountry <- divide(allcountryrisk, by = c("country"), overwrite = TRUE, update=FALSE)
byCountrylong <- divide(allcountryriskmelt, by = c("country"), overwrite = TRUE, update=FALSE)

# vdbConn("WorldBank/vdb", autoYes = TRUE)
# CogFunctions <- function(x) {list(
#   currentRisk = cog(x$risk[nrow(x)], desc="Current Risk Level"),
#   meanDemocracy = cogMean(x$levelDemocracy),
#   RangeDemocracy = cogRange(x$levelDemocracy),
#   meanwarPast5Years = cogMean(x$warPast5Years),
#   RangewarPast5Years = cogRange(x$warPast5Years),
#   meanwarThisYear = cogMean(x$warThisYear),
#   RangewarThisYear = cogRange(x$warThisYear),
#   meanCreditDepositsRatio = cogMean(x$CreditDepositsRatio),
#   RangeCreditDepositsRatio = cogRange(x$CreditDepositsRatio),
#   meanZscore = cogMean(x$Zscore),
#   RangeZscore = cogRange(x$Zscore),
#   meanLiquidAssetsDepositsSTFRatio = cogMean(x$LiquidAssetsDepositsSTFRatio),
#   RangeLiquidAssetsDepositsSTFRatio = cogRange(x$LiquidAssetsDepositsSTFRatio),
#   nObs = cog(sum(!is.na(x$year)), 
#              desc = "number of years for recorded data")
# )}
# CogFunctions(byCountry[[1]][[2]])

vdbConn("WorldBankvJan/vdb", autoYes = TRUE)
CogFunctions <- function(x) {list(
 # currentRiskMax = cog(x$value[x$year==2010 & x$model=="maxValue" & x$variable=="risk"], desc="Current Risk Level, Max Model"),
  currentRisk = cog(x$scaledvalue[x$year==max(x$year[x$model=="Risk Estimate"]) & x$model=="Risk Estimate" & x$variable=="risk"], desc="Current Risk Level"),
  meanRisk = cogMean(x$scaledvalue[x$variable=="risk" & x$model=="Risk Estimate"]),
  RangeRisk = cogRange(x$scaledvalue[x$variable=="risk" & x$model=="Risk Estimate"]) #,
  # currentDemocracy = cog(x$scaledvalue[x$year==max(x$year[x$model=="Risk Estimate"]) & x$model=="Risk Estimate" & x$variable=="levelDemocracy"], desc="Current Democracy Level"),
  # meanDemocracy = cogMean(x$scaledvalue[x$variable=="levelDemocracy" & x$model=="Risk Estimate"]),
  # RangeDemocracy = cogRange(x$scaledvalue[x$variable=="levelDemocracy" & x$model=="Risk Estimate"]),
  # currentwarPast5Years = cog(x$scaledvalue[x$year==max(x$year[x$model=="Risk Estimate"]) & x$model=="Risk Estimate" & x$variable=="warPast5Years"], desc="Current War Past 5 Years Level"),  
  # meanwarPast5Years = cogMean(x$scaledvalue[x$variable=="warPast5Years" & x$model=="Risk Estimate"]),
  # RangewarPast5Years = cogRange(x$scaledvalue[x$variable=="warPast5Years" & x$model=="Risk Estimate"]),
  # currentwarThisYear = cog(x$scaledvalue[x$year==max(x$year[x$model=="Risk Estimate"]) & x$model=="Risk Estimate" & x$variable=="warThisYear"], desc="War This Year Level"),  
  # meanwarThisYear = cogMean(x$scaledvalue[x$variable=="warThisYear" & x$model=="Risk Estimate"]),
  # RangewarThisYear = cogRange(x$scaledvalue[x$variable=="warThisYear" & x$model=="Risk Estimate"]),
  # currentCreditDepositsRatio = cog(x$scaledvalue[x$year==max(x$year[x$model=="Risk Estimate"]) & x$model=="Risk Estimate" & x$variable=="CreditDepositsRatio"], desc="Current Credit to Deposits Ratio Level"),  
  # meanCreditDepositsRatio = cogMean(x$scaledvalue[x$variable=="CreditDepositsRatio" & x$model=="Risk Estimate"]),
  # RangeCreditDepositsRatio = cogRange(x$scaledvalue[x$variable=="CreditDepositsRatio" & x$model=="Risk Estimate"]),
  # currentZscore = cog(x$scaledvalue[x$year==max(x$year[x$model=="Risk Estimate"]) & x$model=="Risk Estimate" & x$variable=="Zscore"], desc="Current Zscore Level"),  
  # meanZscore = cogMean(x$scaledvalue[x$variable=="Zscore" & x$model=="Risk Estimate"]),
  # RangeZscore = cogRange(x$scaledvalue[x$variable=="Zscore" & x$model=="Risk Estimate"]),
  # currentLiquidAssetsDepositsSTFRatio = cog(x$scaledvalue[x$year==max(x$year[x$model=="Risk Estimate"]) & x$model=="Risk Estimate" & x$variable=="LiquidAssetsDepositsSTFRatio"], desc="Current Liquid Assets to Deposits and STF Ratio Level"),  
  # meanLiquidAssetsDepositsSTFRatio = cogMean(x$scaledvalue[x$variable=="LiquidAssetsDepositsSTFRatio" & x$model=="Risk Estimate"]),
  # RangeLiquidAssetsDepositsSTFRatio = cogRange(x$scaledvalue[x$variable=="LiquidAssetsDepositsSTFRatio" & x$model=="Risk Estimate"])
  # # nObs = cog(sum(!is.na(x$year)), 
  #            desc = "number of years for recorded data")
)}
CogFunctions(byCountrylong[[1]][[2]])


##################################
# THIS CODE IS A MESS OF TESTING VARIOUS WAYS TO GET SEPARATE LINE STYLES!!!
##################################

# make and test panel function

# timePanelhc <- function(x){
#   hp <- hPlot(risk ~ year, data = x, type='line', group="model", radius=0)
#   hp
# }
# timePanelhc(byCountry[[1]][[2]])

# make and test panel function

# timePanelhc <- function(x){
#   hp <- hPlot(value ~ year, data = x[x$variable=="risk",], type='line', group="model", radius=0)
#   hp$plotOptions(
#     series=list(dashStyle='LongDash')
#   )
#   hp
# }
# timePanelhc(byCountrylong[[50]][[2]])

# # from our dear friend Ramnanth: http://stackoverflow.com/questions/22522899/r-data-frame-to-json-array-object

# library(RJSONIO)
# z <- byCountrylong[[50]][[2]]
# test <- toJSON(z[z$variable=="risk" & z$model=="Forecast", c(1,5)])
# out <- toJSONArray(
#   toJSONArray2(z[,c(1,5)], names=FALSE, json = FALSE)
#   )

# cat(gsub("\\n", "", out))


# dfToJSON <- function(df){
#     out <- toJSON(
#       toJSONArray2(df[,c(1,5)], names=FALSE, json = FALSE))  
#    # gsub("\\n", "", out)
# }

# timePanelhc <- function(x){
#   hp <- rCharts::Highcharts$new()
#   hp$chart(type="line")

#   hp$series(data=dfToJSON(x[x$model=="multipleImputation",])) 

#  # hp$series(data=x[x$variable=="risk" & x$model=="Forecast", c("value", "year")], dashStyle="LongDash")
#   hp
# }
# timePanelhc(byCountrylong[[50]][[2]])

################################################

timePanelhc <- function(x){
  hp <- hPlot(value ~ year, data = x[x$variable=="risk",], type='line', group="model", radius=0)
  hp$set(height=100)
  hp
}
timePanelhc(byCountrylong[[50]][[2]])


timePanelhcFactors <- function(x){
  hp <- hPlot(scaledvalue ~ year, data = x[x$model=="Risk Estimate",], type='line', group="variable", radius=0)
  hp$set(height=100)
  hp
}
timePanelhcFactors(byCountrylong[[50]][[2]])

# # add display panel and cog function to vdb
# makeDisplay(byCountry,
#             name = "Country_Risk_HighCharts_v3",
#             desc = "Country-Level Risk Ratings By Year, Testing Two Models",
#             paenlFn = timePanelhc, cogFn = CogFunctions,
#             width = 400, height = 400)

# add display panel and cog function to vdb
makeDisplay(byCountrylong,
            name = "Country_Risk_HighCharts",
            desc = "Country-Level Risk Ratings By Year, Testing Two Models",
            panelFn = timePanelhc, cogFn = CogFunctions,
            width = 200, height = 200)
makeDisplay(byCountrylong,
            name = "Country_Risk_Components",
            desc = "Country-Level Risk Components By Year",
            panelFn = timePanelhcFactors, cogFn = CogFunctions,
            width = 400, height = 400)

# runApp("c:/users/kristan/documents/github/trelliscope/inst/worldbank", 
#   launch.browser=TRUE)





# library(lattice)
# countryriskplot <- countryrisk
# countryriskplot$country <- as.factor(countryriskplot$country)
# xyplot(CreditDepositsRatio ~ year| country, data=countryriskplot, type="l")



