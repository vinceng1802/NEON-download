# AUTHOR: Vince Nguyen & Alexander D. Wright
# DATE: 5 Feb 2019
# DESC: Code to manipulate data downloaded from NEON through 'NEON-download_script' (specifically bird and small mammals data)

# TABLE OF CONTENTS

#########
## PART - SET UP WORKING ENVIRONMENT
#########

##
#### INSTALL PACKAGES
##

#install.packages("lubridate")
#install.packages("writexl")
#install.packages("tidyverse")
#install.packages("ggpubr")

library(lubridate)
library(writexl)
library(tidyverse)
library(ggplot2)
library(ggpubr)
library(dplyr)

##
#### SET WORKING DIRECTORY AND IMPORT NEON DATA
##

dir <- "C:/Users/Vince/Desktop/Zipkin Lab/NEON/NEON-download"
setwd(dir)

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

##
#### SET WORKING DIRECTORY AND IMPORT HUBBARD BROOK DATA
##

setwd("C:/Users/Vince/Desktop/Zipkin Lab/NEON/FW__foliage_gleaning_bird_dataset")
birdCount <- readRDS("Abundance_array_Zipkin_species.rds")

##
#### SET WORKING DIRECTORY AND IMPORT BBS DATA
##

setwd("C:/Users/Vince/Desktop/Zipkin Lab/NEON/USGS_BBS-dataset")
load("countBBS.R")

#########
## PART - DATA EXPLORATION of NEON
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
bartBird <- birCount[birCount$siteID == 'BART', c('siteID','plotID','pointID','startDate','pointCountMinute','taxonID','vernacularName','clusterSize')]
target <- c('AMRE',
            'BAWW',
            'BHVI',
            'BLBW',
            'BLPW',
            'BTBW',
            'BTNW',
            'CAWA',
            'MAWA',
            'MYWA',
            'NAWA',
            'OVEN',
            'REVI')
bartBird <- bartBird %>% filter(taxonID %in% target)

# levels(bartBird$vernacularName) <- c(levels(bartBird$vernacularName), 
#                                      'Myrtle Warbler', 'Nashville Warbler', 'Blackpoll Warbler')
# bartBird$vernacularName

##
#### MANAGE BART DATA 
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

## Add dummy rows of missing species
bartBird <- bartBird %>% select(siteID, plotID, pointID, taxonID, clusterSize, year, month, day) 
missSpp <- data.frame(siteID = rep('BART',3), plotID=rep('BART_025'), pointID=rep("C1",3), 
                      taxonID=c('MYWA', 'NAWA', 'BLPW'), 
                      clusterSize = rep(0, 3), year=rep(2015, 3), month=rep(6, 3), day=rep(14,3))

bartBird <- rbind(bartBird,missSpp)


#Reset Factor levels
bartBird$taxonID <- droplevels(bartBird$taxonID)
#Determining birds found per species
bartBirdSum <- aggregate(bartBird$clusterSize, by = list(bartBird$taxonID), FUN = function(x) sum(x))
colnames(bartBirdSum) <- c("Species", "Count")

#Change NAs to 0
bartBird$clusterSize[is.na(bartBird$clusterSize)] <- 0
bartBirdSum[is.na(bartBirdSum)] <- 0
#Export data as a table
#write_xlsx(x = bartBird, path = "bartBird.xlsx")

#Select species of interest
aa <- ggplot(data= bartBirdSum, aes(x=Species, y=Count, fill=Species)) + 
        geom_bar(stat="identity") +
        ggtitle("NEON (2015-2018)") +
        scale_y_continuous(breaks=seq(0,400,100)) +
        theme(plot.title=element_text(size = 8), 
              axis.text.x=element_blank(),
              axis.text.y=element_text(size = 6),
              axis.ticks.x=element_blank(),
              axis.title.x=element_blank(),
              axis.title.y=element_blank(),
              legend.text=element_text(size=6),
              legend.title=element_blank(), 
              legend.position="bottom"
              ) +
        guides(fill = guide_legend(nrow = 2))
       

##
#### Hubbard Book Data Manipulate and Plotting
##

#Finding Taxon IDs
birdCount[1,1,1,]

birdCount <- birdCount[,,12:20,]
count <- as.data.frame(apply(birdCount, c(4), sum, na.rm=T))
colnames(count) <- "Count"
hubCount <- data.frame(Count = count$Count, Spp = rownames(count), DataSource = rep("Hubbard Brook",13))

bb <- ggplot(data= hubCount, aes(x=Spp, y=Count, fill=Spp)) + 
        geom_bar(stat="identity") +
        ggtitle("LTER (2010-2018)") +
        labs(x="Species", fill = "Species") +
        scale_y_continuous(breaks=seq(0,5000,2000)) +
        theme(plot.title=element_text(size = 8),
              axis.text.x=element_blank(),
              axis.text.y=element_text(size = 6),
              axis.ticks.x=element_blank(),
              axis.title.x=element_blank(),
              axis.title.y=element_blank()
              )

##
#### USGS Data Manipulation and Plotting
##

cc <- ggplot(data=countBBS, aes(x=taxonID, y=Count, fill=taxonID)) + 
  geom_bar(stat="identity") +
  ggtitle("USGS (2010-2017)") +
  scale_y_continuous(breaks=seq(0,7000,2000)) +
  theme(plot.title=element_text(size = 8),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size = 6),
        axis.ticks.x=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position = "none")

##
#### Ebird Data Manipulation and Plotting
##

dd <- ggplot(data= bartBirdSum, aes(x=Species, y=Count, fill=Species)) + 
  geom_bar(stat="identity") +
  ggtitle("eBird (2010-2018)") +
  scale_y_continuous(breaks=seq(0,400,100)) +
  theme(plot.title=element_text(size = 8),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size = 6),
        axis.ticks.x=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position = "none")


##
#### Joining Plots from different data sources together
##


## ALL TOGETHER TO MAKE PUBLICATION QUALITY FIGURE
#Set Working Directory
setwd("C:/Users/Vince/Desktop/Zipkin Lab/NEON/NEON-download")
#Set image specifications
png('Figure1.png', width = 3.9, height = 2.86, units = 'in', res = 450)
#Make plot
figure <- ggarrange(aa, bb, cc, dd,
                    ncol = 2, nrow = 2, common.legend = T, legend = "bottom")
#ggarrange(bbaa,covs_rich,nrow=2,heights=c(1,1)) #meta_all <- 

#figure <- annotate_figure(figure, left=text_grob('Count', rot = 90), 
#                          bottom=text_grob('Species'))
figure
#Save plot
dev.off()
#1000*700

##
#### SRER MAMMAL DATA EXPLORATION
##

#Subsetting columns of interest for Vince
srerMam <- mamTrap %>% filter(siteID == 'SRER') %>% select(siteID, plotID, trapCoordinate, collectDate, tagID, taxonID, scientificName)
  #mamTrap[mamTrap$siteID == 'SRER', c('siteID','plotID','pointID','collectDate','pointCountMinute','taxonID','clusterSize')]
nrow(srerMam)
sppSRER <- srerMam %>% distinct(scientificName) %>% filter(!str_detect(scientificName, 'sp.'))
srerMam <- srerMam %>% filter(!str_detect(scientificName, 'sp.'), .preserve = TRUE) 

#Add years from 'collectDate' column
srerMam <- srerMam %>% mutate(YEAR = year(collectDate))
min(srerMam$YEAR)

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

#Add years from 'collectDate' column
jornMam <- jornMam %>% mutate(YEAR = year(collectDate))
min(jornMam$YEAR)

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
names(mergedSpec) <- c("Spp", "SRER", "JORN")

mergedSpec <- mergedSpec %>% filter(!(SRER == 0 & JORN ==0))
nrow(mergedSpec[mergedSpec$SRER > 0 & mergedSpec$JORN == 0])

# SUM OF ALL INDIVIDUALS PER SITE
sum(mergedSpec["SRER"])
sum(mergedSpec["JORN"])

#Export data as a table
#write_xlsx(x = mergedSpec, path = "MamSrerJorn.xlsx")