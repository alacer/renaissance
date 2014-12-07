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
