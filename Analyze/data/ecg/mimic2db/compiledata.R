setwd("c:/users/kristan/documents/github/trelliscope/data/mimic2db/alarms")

filenames <- Sys.glob("*.txt")  # however you get the list of file
allData <- lapply(filenames, function(.file){
  data<-read.fwf(.file, widths=c(14,11,10,7,4,5,5,18),sep="?",strip.white=TRUE, skip=1)
  data$id<-substring(.file, 1, 6)
  data$type <- "Alarm"
  data    # return the dataframe
})
# combine into a single dataframe
alarms <- do.call(rbind, allData)
names(alarms) <- c("Time", "Date", "Sample", "Type", "Sub", "Chan", "Num", "Aux", "id", "type")

setwd("c:/users/kristan/documents/github/trelliscope/data/mimic2db/annot")

filenames <- Sys.glob("*.txt")  # however you get the list of file
allData <- lapply(filenames, function(.file){
  data<-read.fwf(.file, widths=c(14,11,10,7,4,5,5,18),sep="?",strip.white=TRUE, skip=1)
  data$id<-substring(.file, 1, 6)
  data$type <- "Annotation"
  data    # return the dataframe
})
# combine into a single dataframe
annotations <- do.call(rbind, allData)
names(annotations) <- c("Time", "Date", "Sample", "Type", "Sub", "Chan", "Num", "Aux", "id", "type")


alarms$SampleN <- as.numeric(alarms$Sample)
alarms <- alarms[!is.na(alarms$SampleN),]
annotations$SampleN <- as.numeric(annotations$Sample)
alldata <- merge(alarms, annotations, by=c("id", "SampleN"), all=TRUE)

setwd("endtimes")
filenames <- Sys.glob("*.txt")  # however you get the list of file
allData <- lapply(filenames, function(.file){
  data<-read.fwf(.file, widths=c(17,14,26),sep="?",strip.white=TRUE)
  data$id<-substring(.file, 1, 6)
  data    # return the dataframe
})
# combine into a single dataframe
endtimes <- do.call(rbind, allData)
names(endtimes) <- c("Sample", "TimeElapsed", "Date", "id")
timeelapsed <- endtimes[,c("TimeElapsed","id")]
timeelapsed$hours <- sub(":.*$", "", timeelapsed$TimeElapsed)
  
# alldata2 <- merge(alldata, timeelapsed, by="id", all=TRUE)
# 
# metricdata <- alldata2
# metricdata$alarm[metricdata$type.x=="Alarm"] <- 1

alldata$alarm[alldata$type.x=="Alarm"] <- 1
alarmsperpatientperhour <- aggregate(alldata$alarm, by=list(alldata$id), sum)

alarmtypesperpatientperhour <- aggregate(alldata$alarm, by=list(alldata$id, alldata$Aux.x), sum)

alarmtypesperhour <- aggregate(alldata$alarm, by=list(alldata$Aux.x), sum)

test <- match(alarmsperpatientperhour$Group.1, timeelapsed$id)
alarmsperpatientperhour$NHours <- as.numeric(timeelapsed$hours[test])
alarmsperpatientperhour$rate <- alarmsperpatientperhour$x/alarmsperpatientperhour$NHours

test <- match(alarmtypesperpatientperhour$Group.1, timeelapsed$id)
alarmtypesperpatientperhour$NHours <- as.numeric(timeelapsed$hours[test])
alarmtypesperpatientperhour$rate <- alarmtypesperpatientperhour$x/alarmtypesperpatientperhour$NHours

alarmtypesperhour$NHours <- sum(alarmsperpatientperhour$NHours, na.rm=TRUE)
alarmtypesperhour$rate <- alarmtypesperhour$x/alarmtypesperhour$NHours

apph <- alarmsperpatientperhour[order(alarmsperpatientperhour$rate, decreasing=TRUE),]

atpph <- alarmtypesperpatientperhour[order(alarmtypesperpatientperhour$rate, decreasing=TRUE),]

atph <- alarmtypesperhour[order(alarmtypesperhour$rate, decreasing=TRUE),]


#90% of the patients trigger 9 or fewer alarms per hour
#Of the 10% of patients that trigger 10 or more alarms an hour, this makes up a total of 26% of the alarms

#80% trigger 6 or fewer alarms; of those that trigger more than six alarms, this makes up 40% of the alarms

#filter down to non-actionable alarms
nonactionable <- alldata[alldata$Sub.x!="3" & alldata$Sub.x!="A",]

nonactionable$alarm[nonactionable$type.x=="Alarm"] <- 1
alarmsperpatientperhour <- aggregate(nonactionable$alarm, by=list(nonactionable$id), sum)

alarmtypesperpatientperhour <- aggregate(nonactionable$alarm, by=list(nonactionable$id, nonactionable$Aux.x), sum)

alarmtypesperhour <- aggregate(nonactionable$alarm, by=list(nonactionable$Aux.x), sum)

test <- match(alarmsperpatientperhour$Group.1, timeelapsed$id)
alarmsperpatientperhour$NHours <- as.numeric(timeelapsed$hours[test])
alarmsperpatientperhour$rate <- alarmsperpatientperhour$x/alarmsperpatientperhour$NHours

test <- match(alarmtypesperpatientperhour$Group.1, timeelapsed$id)
alarmtypesperpatientperhour$NHours <- as.numeric(timeelapsed$hours[test])
alarmtypesperpatientperhour$rate <- alarmtypesperpatientperhour$x/alarmtypesperpatientperhour$NHours

alarmtypesperhour$NHours <- sum(alarmsperpatientperhour$NHours, na.rm=TRUE)
alarmtypesperhour$rate <- alarmtypesperhour$x/alarmtypesperhour$NHours

apph <- alarmsperpatientperhour[order(alarmsperpatientperhour$rate, decreasing=TRUE),]

atpph <- alarmtypesperpatientperhour[order(alarmtypesperpatientperhour$rate, decreasing=TRUE),]

atph <- alarmtypesperhour[order(alarmtypesperhour$rate, decreasing=TRUE),]

#20% of patients trigger 48% of non-actionable alarms
#10% of patients trigger 30% of non-actionable alarms

#solution for "most patients":
#30 minute roll-ups:
nonactionable$Time <- strptime(nonactionable$Time.x, format="[%H:%M:%S")
head(nonactionable)
nonactionable$Date <- strptime(nonactionable$Date.x, format="%d/%m/%Y")
nonactionable$DayHour <- paste(format(nonactionable$Time, "%H"), format(nonactionable$Date, "%d"), sep="-")

save(nonactionable, file="nonactionabledata.RData")
###############

setwd("waveforms_02-02")
filenames <- Sys.glob("*.csv")  # however you get the list of file
allData02 <- lapply(filenames, function(.file){
  data <- read.csv(.file, header=TRUE, stringsAsFactors=FALSE)
  data$Patient <- substring(.file, 1, 6)
  data$Hour <- "02-02"
  data <- data[-1,]
  datamelt <- melt(data, id=c("Patient", "X.Elapsed.time.", "Hour"))
  datamelt$Time <- sub(".*?:", "", data$X.Elapsed.time.)
  datamelt$Time <- strptime(datamelt$Time, format="%M:%OS'")  
  data <- datamelt[,-2]
  names(data) <- c("Patient", "Hour", "LeadSignal", "Value", "Time")
  data$LeadSignal <- sub("X.", "", data$LeadSignal)
  data$LeadSignal <- sub(".", "", data$LeadSignal)
  data
})

setwd("../waveforms_14-29")
filenames <- Sys.glob("*.csv")  # however you get the list of file
allData14 <- lapply(filenames, function(.file){
  data <- read.csv(.file, header=TRUE, stringsAsFactors=FALSE)
  data$Patient <- substring(.file, 1, 6)
  data$Hour <- "14-29"
  data <- data[-1,]
  datamelt <- melt(data, id=c("Patient", "X.Elapsed.time.", "Hour"))
  datamelt$Time <- sub(".*?:", "", data$X.Elapsed.time.)
  datamelt$Time <- strptime(datamelt$Time, format="%M:%OS'")  
  data <- datamelt[,-2]
  names(data) <- c("Patient", "Hour", "LeadSignal", "Value", "Time")
  data$LeadSignal <- sub("X.", "", data$LeadSignal)
  data$LeadSignal <- sub(".", "", data$LeadSignal)
  data    # return the dataframe
})


alldata02 <- do.call(rbind, allData02)
alldata14 <- do.call(rbind, allData14)

save(alldata02, file="../alldata02.RData")
save(alldata14, file="../alldata14.RData")


#waveformdata <- rbind(alldata02, alldata14)


# allDataList <- vector("list")
# allDataList[[1]] <- vector("list")
# allDataList[[1]]$key <- NA
# allDataList[[1]]$data <- allData02[[1]]
# counter <- 1
# for(i in 2:length(allData02)){
#   if(allData02[[i]]$Patient[1]==allData02[[i-1]]$Patient[1]){
#   allDataList[[counter]]$key <- paste("Patient=",allData02[[i]]$Patient[1],"|Hour=",allData02[[i]]$Hour,sep="")
#   allDataList[[counter]]$data <- rbind(allDataList[[counter]]$data, allData02[[i]]) 
#   }
#   if(allData02[[i]]$Patient[1]!=allData02[[i-1]]$Patient[1]){
#   counter <- counter+1
#   allDataList[[counter]] <- vector("list")
#   allDataList[[counter]]$key <- paste("Patient=",allData02[[i]]$Patient[1],"|Hour=",allData02[[i]]$Hour,sep="")   
#   allDataList[[counter]]$data <- allData02[[i]]
#   }
# }
# counter <- counter+1
# allDataList[[counter]] <- vector("list")
# allDataList[[counter]]$key <- NA
# allDataList[[counter]]$data <- allData14[[1]]
# for(i in 2:length(allData14)){
#   if(allData14[[i]]$Patient[1]==allData14[[i-1]]$Patient[1]){
#   allDataList[[counter]]$key <- paste("Patient=",allData14[[i]]$Patient[1],"|Hour=",allData14[[i]]$Hour,sep="")
#   allDataList[[counter]]$data <- rbind(allDataList[[counter]]$data, allData14[[i]]) 
#   }
#   if(allData14[[i]]$Patient[1]!=allData14[[i-1]]$Patient[1]){
#   counter <- counter+1
#   allDataList[[counter]] <- vector("list")
#   allDataList[[counter]]$key <- paste("Patient=",allData14[[i]]$Patient[1],"|Hour=",allData14[[i]]$Hour,sep="")   
#   allDataList[[counter]]$data <- allData14[[i]]
#   }
# }

# waveformdata <- allDataList

#save(waveformdata, file="../waveformdata.RData")
