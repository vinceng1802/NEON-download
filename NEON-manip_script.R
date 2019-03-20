# AUTHOR: Vince Nguyen & Alexander D. Wright
# DATE: 5 Feb 2019
# DESC: Code to manipulate data downloaded from NEON through 'NEON-download_script' (specifically bird and small mammals data)

# TABLE OF CONTENTS

#########
## PART - SET UP WORKING ENVIRONMENT
#########

##
#### SET WORKING DIRECTORY 
##

dir <- "C:/Users/Vince/Desktop/Zipkin Lab/NEON/NEON-download"
setwd(dir)

##
#### INSTALL PACKAGES
##

#install.packages("lubridate")
#install.packages("writexl")
#install.packages("tidyverse")

library(lubridate)
library(writexl)
library(tidyverse)

##
#### IMPORTING DATA
##

# Credit to ANG from Stackoverflow for code to import data
# https://stackoverflow.com/questions/46682818/read-a-csv-file-in-a-zipped-folder-with-r-without-unzipping

# BIRD DATA 
birds <- as.character(unzip("Birds.zip", list = TRUE)$Name)
# LOAD COUNT DATA
birCount <- read.csv(unz("Birds.zip", "Birds/brd_countdata.csv"), header = TRUE,
                 sep = ",") 
# LOAD PER PLOT DATA
birPlot <- read.csv(unz("Birds.zip", "Birds/brd_perpoint.csv"), header = TRUE,
                 sep = ",") 

# MAMMAL DATA 
mammals <- as.character(unzip("Mammals2018.zip", list = TRUE)$Name)
# LOAD PLOT DATA
mamPlot <- read.csv(unz("Mammals2018.zip", "Mammals2018/mam_perplotnight.csv"), header = TRUE,
                          sep = ",") 
# LOAD TRAP DATA
mamTrap <- read.csv(unz("Mammals2018.zip", "Mammals2018/mam_pertrapnight.csv"), header = TRUE,
                           sep = ",")

# LOAD FIELD SITES
fieldSites <- read.csv(unz("field-sites.zip", "field-sites.csv"), header = TRUE,
                       sep = ",")

#########
## PART - DATA EXPLORATION
#########

# CALCULATE PLOTS PER SAMPLING SITE FOR MAMMALS
newMamPlot <- unique(mamPlot[,4:7])
mamPlotNum <- tapply(newMamPlot$plotID, newMamPlot$siteID, 
                          FUN = function(x)length(unique(x)))
# CALCULATE SAMPLING OCCASIONS PER PLOT FOR MAMMALS
mamSampNum <- tapply(newMamPlot$collectDate, newMamPlot$plotID, 
                     FUN = function(x)length(unique(x)))

# CALCULATE PLOTS PER SAMPLING SITE FOR BIRDS
newBirPlot <- unique(birPlot[,4:15])
birPlotNum <- tapply(newBirPlot$plotID, newBirPlot$siteID, 
                         FUN = function(x)length(unique(x)))
# CALCULATE SAMPLING OCCASIONS PER PLOT FOR BIRDS
birSampNum <- tapply(newBirPlot$startDate, newBirPlot$plotID, 
                     FUN = function(x)length(unique(x)))

# CHECK WHICH SITES HAVE MAMMAL/BIRD DATA
newFieldSites <- unique(fieldSites[,1:5])
mergedMam <- merge(x = newFieldSites, y = data.frame(siteID = unique(newMamPlot$siteID)), 
                     by.x = "Site.ID", by.y = "siteID", all = F)
mergedMam$Mam <- 1
mergedBir <- merge(x = newFieldSites, y = data.frame(siteID = unique(newBirPlot$siteID)),
                   by.x = "Site.ID", by.y = "siteID", all = F)
mergedBir$Bir <- 1
mergedALL <- merge(x = mergedBir, y = mergedMam,
                   by="Site.ID", all = T)
mergedALL <- mergedALL[,c('Site.ID', 'Bir','Mam')]
mergedALL <- merge(newFieldSites,mergedALL,by='Site.ID',all=T)

mergedALL[is.na(mergedALL)] <- 0
nrow(mergedALL[mergedALL$Bir == 1,])
nrow(mergedALL[mergedALL$Mam == 1,])

nrow(mergedALL[mergedALL$Bir == 1 & mergedALL$Mam == 1,])
nrow(mergedALL[mergedALL$Bir == 0 & mergedALL$Mam == 0,])

nrow(mergedALL[mergedALL$Bir == 1 & mergedALL$Mam == 0,])
nrow(mergedALL[mergedALL$Bir == 0 & mergedALL$Mam == 1,])

##
#### BART BIRD DATA EXPLORATION
##

#Subsetting columns of interest for Vince
bartBird <- birCount[birCount$siteID == 'BART', c('siteID','plotID','pointID','startDate','pointCountMinute','taxonID','clusterSize')]
nrow(bartBird)

#Reformat columns
bartBird$taxonID <- factor(bartBird$taxonID)

##
#### MANAGE DATA 
##

#bartBird
#Manipulating time and date data 
#Specifying the format of time and date data
bartBird$startDate <- as.POSIXct(bartBird$startDate,
                                  format="%Y-%m-%d T %H Z",
                                  tz = 'GMT' #ALL NEON DATA IS IN THE SAME TIME ZONE, Greenwich Mean Time (GMT=UTC)
)

bartBird$year <- year(bartBird$startDate)
bartBird$month <- month(bartBird$startDate)
bartBird$day <- day(bartBird$startDate)

#Determining number of sampling occasions
nSamp <- unique(bartBird[,c('siteID','plotID','pointID','pointCountMinute','taxonID','clusterSize')])
nrow(nSamp)

#Determining number of species found at BART
length(unique(bartBird$taxonID))
#Determining birds found per species
bartBirdSum <- tapply(bartBird$clusterSize, INDEX = list(bartBird$year, bartBird$taxonID), FUN = function(x) sum(x))

#Change NAs to 0
bartBird$clusterSize[is.na(bartBird$clusterSize)] <- 0
bartBirdSum[is.na(bartBirdSum)] <- 0
#Export data as a table
#write_xlsx(x = bartBird, path = "bartBird.xlsx")

##
#### SRER MAMMAL DATA EXPLORATION
##

#Subsetting columns of interest for Vince
srerMam <- mamTrap %>% filter(siteID == 'SRER') %>% select(siteID, plotID, trapCoordinate, collectDate, tagID, taxonID, scientificName)
  #mamTrap[mamTrap$siteID == 'SRER', c('siteID','plotID','pointID','collectDate','pointCountMinute','taxonID','clusterSize')]
nrow(srerMam)
sppSRER <- srerMam %>% distinct(scientificName) %>% filter(!str_detect(scientificName, 'sp.'))
srerMam <- srerMam %>% filter(!str_detect(scientificName, 'sp.'), .preserve = TRUE) 

#Determining mammals found per species
srerMamSum <- srerMam %>% filter(str_detect(tagID, 'NEON'), .preserve = TRUE) 
#srerMamSum$Count <- 1
#srerMamSum <- tapply(srerMamSum$Count, INDEX = list(srerMamSum$scientificName,srerMamSum$tagID), FUN = function(x) sum(x))

xSRER <- data.frame(Spp = sppSRER$scientificName, Count = NA)
for(i in 1:nrow(sppSRER)){
  ySRER <- srerMamSum %>% filter(scientificName == sppSRER$scientificName[i]) %>% distinct(tagID)
  xSRER[i,2] <- nrow(ySRER)
}

##
#### JORN MAMMAL DATA EXPLORATION
##

#Subsetting columns of interest for Vince
jornMam <- mamTrap %>% filter(siteID == 'JORN') %>% select(siteID, plotID, trapCoordinate, collectDate, tagID, taxonID, scientificName)
#mamTrap[mamTrap$siteID == 'SRER', c('siteID','plotID','pointID','collectDate','pointCountMinute','taxonID','clusterSize')]
nrow(jornMam)
sppJORN <- jornMam %>% distinct(scientificName) %>% filter(!str_detect(scientificName, 'sp.'))
jornMam <- jornMam %>% filter(!str_detect(scientificName, 'sp.'), .preserve = TRUE) 

#Determining mammals found per species
jornMamSum <- jornMam %>% filter(str_detect(tagID, 'NEON'), .preserve = TRUE) 
#srerMamSum$Count <- 1
#srerMamSum <- tapply(srerMamSum$Count, INDEX = list(srerMamSum$scientificName,srerMamSum$tagID), FUN = function(x) sum(x))

xJORN <- data.frame(Spp = sppJORN$scientificName, Count = NA)
for(i in 1:nrow(sppJORN)){
  yJORN <- jornMamSum %>% filter(scientificName == sppJORN$scientificName[i]) %>% distinct(tagID)
  xJORN[i,2] <- nrow(yJORN)
}

# CHECK WHICH SITES HAVE UNIQUE SPECIES
mergedSpec <- merge(x = xSRER, y = xJORN, by = "Spp", all = T)

mergedSpec[is.na(mergedSpec)] <- 0

nrow(mergedSpec[mergedSpec$Count.x > 0 & mergedSpec$Count.y == 0,])