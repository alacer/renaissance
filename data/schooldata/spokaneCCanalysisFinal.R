
setwd("github/trelliscope/data/schooldata")

# install.packages("SGP")
# install.packages("devtools") # if not installed
# library(devtools)
# install_github("tesseradata/datadr")
# install_github("tesseradata/trelliscope")
# install.packages("SGPdata")

library(datadr); library(trelliscope)
library(SGP)
library(SGPdata)
library(reshape2)


###
###  Configure SGP analysis
###

my.custom.config <- list(
  MATHEMATICS.2012_2013 = list(
  	sgp.content.areas=rep("MATHEMATICS", 3), # Note, must be same length as sgp.panel.years
  	sgp.panel.years=c('2010_2011', '2011_2012', '2012_2013'),
  	sgp.grade.sequences=list(4:6)
  ),
  READING.2012_2013 = list(
  	sgp.content.areas=rep("READING", 3),
  	sgp.panel.years=c('2010_2011', '2011_2012', '2012_2013'),
  	sgp.grade.sequences=list(4:6)
  )
)

#Run SGP analysis; see help files for more details

Demonstration_SGP <- prepareSGP(sgpData_LONG)
Demonstration_SGP <- analyzeSGP(Demonstration_SGP,
	sgp.config=my.custom.config,
	sgp.percentiles.baseline = TRUE,
	sgp.projections.baseline = TRUE,
	sgp.projections.lagged.baseline = FALSE,
	simulate.sgps=FALSE)

#pull out reading scores
resultsReadingProjection <- Demonstration_SGP@SGP$SGProjections$READING.2012_2013

##################

# note: mma=multilevel modeling analysis (but, not used here)
mmadata <- sgpData_LONG[sgpData_LONG$YEAR %in% c('2010_2011', '2011_2012', '2012_2013'),]
mmadata <- mmadata[mmadata$GRADE %in% c(4,5,6),]
mmadata$IDFac <- factor(mmadata$ID)

mmareadingdata <- mmadata[mmadata$CONTENT_AREA=="READING",]

#reshape data to merge with results
mmadatamelt <- melt(mmareadingdata[,c("ID", "GRADE", "SCALE_SCORE")], id=c("ID", "GRADE"))
mmadatacast <- dcast(mmadatamelt, ID ~ GRADE + variable, sum)

#save covariates
covars <- melt(mmareadingdata[,c("ID", "YEAR", "GENDER", "ETHNICITY", 
	"FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "SCHOOL_NUMBER",
	"DISTRICT_NUMBER")], id=c("ID", "GENDER", "ETHNICITY", 
	"FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "SCHOOL_NUMBER",
	"DISTRICT_NUMBER"))
covarscast <- dcast(covars, ID + GENDER + ETHNICITY + FREE_REDUCED_LUNCH_STATUS + 
	ELL_STATUS + IEP_STATUS + SCHOOL_NUMBER + DISTRICT_NUMBER ~ variable)

#merge results data with basic ID data
resultsReading <- merge(resultsReadingProjection, mmadatacast, by="ID", all.x=TRUE)

#merge reading results with covariates
resultsReadingcovars <- merge(resultsReading, covarscast[,-c(ncol(covarscast))], by="ID", all.x=TRUE)

#reshape to long for plotting
resultsLong <- melt(resultsReadingcovars, id=c("ID", "GENDER", "ETHNICITY", 
	"FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "SCHOOL_NUMBER",
	"DISTRICT_NUMBER"))

#distinguish between grade levels
resultsLong$Time <- NA
resultsLong$Time[resultsLong$variable=='4_SCALE_SCORE'] <- 4
resultsLong$Time[resultsLong$variable=='5_SCALE_SCORE'] <- 5
resultsLong$Time[resultsLong$variable=='P1_PROJ_YEAR_1_CURRENT'] <- 6
resultsLong$Time[resultsLong$variable=='P20_PROJ_YEAR_1_CURRENT'] <- 6
resultsLong$Time[resultsLong$variable=='P40_PROJ_YEAR_1_CURRENT'] <- 6
resultsLong$Time[resultsLong$variable=='P61_PROJ_YEAR_1_CURRENT'] <- 6
resultsLong$Time[resultsLong$variable=='P81_PROJ_YEAR_1_CURRENT'] <- 6
resultsLong$Time[resultsLong$variable=='P99_PROJ_YEAR_1_CURRENT'] <- 6

#extract 61st percentile projection for grade 6
resultsLong61 <- resultsLong[resultsLong$variable %in% c("4_SCALE_SCORE",
 "5_SCALE_SCORE", "P61_PROJ_YEAR_1_CURRENT"),]

#remove scores of "0" or NAs (ie, didn't take the test)
resultsLong61noZero <- resultsLong61[resultsLong61$value!=0,]
resultsLong61noZero <- resultsLong61noZero[!is.na(resultsLong61noZero$ID),]
results <- resultsLong61noZero[order(resultsLong61noZero$ID, resultsLong61noZero$Time),]

#divide results by school, gender, ethnicity, IEP, Free-reduced lunch status
bySchoolGenderEthnicty <- divide(results, 
  by = c("SCHOOL_NUMBER", "GENDER", "ETHNICITY", "IEP_STATUS", "FREE_REDUCED_LUNCH_STATUS"))
	
# make a time series trelliscope display
vdbConn("SchoolData/vdb", autoYes = TRUE)

# make and test panel function
timePanel <- function(x)
  xyplot(value ~ Time, group=ID,
    data = x, auto.key = FALSE, type="l", 
    ylab="Score", xlab="Year in School")

timePanel(bySchoolGenderEthnicty[[1]][[2]])

# make and test cognostics function
scoreCog <- function(x) { list(
  meanScore = cogMean(x$value),
  scoreRange = cogRange(x$value),
  nObs = cog(sum(!is.na(x$value)), 
    desc = "number of students")
)}
scoreCog(bySchoolGenderEthnicty[[1]][[2]])

# add display panel and cog function to vdb
makeDisplay(bySchoolGenderEthnicty,
  name = "Student_Achievement_Demographicsv3",
  desc = "Student Scores Grades 4-5 Predicting Grade 6",
  panelFn = timePanel, cogFn = scoreCog,
  width = 400, height = 400,
  lims = list(x = "same")
)

# view the display (using trelliscope)
#view()      

#use Alacer-Branded Trelliscope
library(shiny)
runApp("../../inst/TrelliscopeViewerAlacer")



