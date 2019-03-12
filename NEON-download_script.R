# AUTHOR: Vince Nguyen & Alexander D. Wright
# DATE: 10 Nov 2018
# DESC: Code to access, download, and reformat data from NEON (specifically bird and small mammals data)

#TABLE OF CONTENTS
  #SET UP WORKING ENVIRONMENT       Line 17
    #Set Working Directory          Line 21
    #Install Packages               Line 28
  #DOWNLOAD DATA FROM NEON          Line 50
    #Bird Data                      Line 54
    #Mammal Data                    Line 79
  #IMPORT DATA                      Line 95
    #Bird Data                      Line 99
    #Mammal Data                    Line 111
  #DATA EXPLORATION                 Line 120

#########
## PART - SET UP WORKING ENVIRONMENT
#########

##
#### SET WORKING DIRECTORY 
##

dir <- "C:/Users/Vince/Desktop/Zipkin Lab/NEON"
setwd(dir)

##
#### INSTALL PACKAGES
##

#Install packages
#Provided code that downloads all packages at once
install.packages("raster")
install.packages("neonUtilities")
install.packages("devtools")

source("http://bioconductor.org/biocLite.R")
biocLite("rhdf5")
library(devtools)
install_github("NEONScience/NEON-geolocation/geoNEON")

# Necessary packages
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)


#########
## PART - DOWNLOAD DATA FROM NEON (THIS STEP ONLY NEEDS TO BE DONE ONCE)
#########

##
#### BIRDS
##

# Download data from portal via R
options(stringsAsFactors = F)
# download observational data with zipsByProduct() from the data portal remotely
#Only have to do this step once (the first time you work the data)
  #Birds (Need to create folder - see dirPaste() before running code)
dirPaste <- paste(dir,'/Birds', sep = "")
  # dpID and savepath ae the only things that need to change
zipsByProduct(dpID = "DP1.10003.001",   #DPI for Bird Point Count data, you get that from the Data Portal in-dev browser
              site = 'all', #dont change
              package = 'basic', #dont change
              check.size = T, #dont change
              savepath = dirPaste)
  #After running this function, you need to type 'y' in the console, and hit enter
#This script to download Bird data was run on 'Day' 'Month' 'Year'


#now stack downloaded data
dirPaste <- paste(dir,'/Data/Birds/filesToStack10003', sep = "") #10003 refers to the DPI
stackByTable(dirPaste, folder = T)
#This script to stack data was run on 'Day' 'Month' 'Year'

##
#### MAMMALS
##

# Download data from portal via R
options(stringsAsFactors = F)
dirPasteM <- paste(dir,'/Mammals2018', sep = "")
zipsByProduct(dpID = "DP1.10072.001",   #DPI
              site = 'all', #dont change
              package = 'basic', #dont change
              check.size = T, #dont change
              savepath = dirPasteM)
#This script to download Mammal data was run on 'Day' 'Month' 'Year'

dirPasteM <- paste(dir,'/Mammals2018/filesToStack10072', sep = "") #refers to the DPI
stackByTable(dirPasteM, folder = T)
#This script to stack Mammal data was run on 'Day' 'Month' 'Year'

#########
## PART - IMPORT DATA 
#########

##
#### BIRDS
##

# Read in Bird Data

#Count Data
birdCount <- read.delim(paste(dir, "/Birds/filesToStack10003/stackedFiles/brd_countdata.csv", sep = ""), sep = ",")
#Repeat for points data
birdPoint <- read.delim(paste(dir, "/Birds/filesToStack10003/stackedFiles/brd_perpoint.csv", sep = ""), sep = ",")


##
#### MAMMALS
##

mamPlot <- read.delim(paste(dir, "/Mammals2018/filesToStack10072/stackedFiles/mam_perplotnight.csv", sep = ""), sep = ",")
mamTrap <- read.delim(paste(dir, "/Mammals2018/filesToStack10072/stackedFiles/mam_pertrapnight.csv", sep = ""), sep = ",")


#########
## PART - DATA EXPLORATION 
#########

# Address questions from Elise (as comments in Word document)

str(birdPoint)

# How  many NEON sites are samples?
length(unique(birdPoint$siteID))
#43 NEON sites

#How man plots are sampled in total?
length(unique(birdPoint$plotID))
#586 plots in total across the 43 sites

#How are those plots broken down by NEON site?


