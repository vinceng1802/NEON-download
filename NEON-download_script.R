# AUTHOR: Vince Nguyen & Alexander D. Wright
# DATE: 10 Nov 2018
# DESC: Code to access, download, and reformat data from NEON (specifically bird, small mammals, and beetle data)


#TABLE OF CONTENTS  ( TO BE FINISHED LATER)
#SET UP WORKING ENVIRONMENT       Line 15
#Set Working Dierctory            Line 19
#Install Packages                 Line 28
#DOWNLOAD DATA FROM NEON          Line 49
#BIRD DATA                        Line 53
#MAMMAL DATA                      Line 77
#BEETLE DATA                      Line 94
#IMPORT DATA                      Line 111
#BIRD DATA                        Line 118
#MAMMAL DATA                      Line 130

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

# #Install packages
# #Provided code that downloads all packages at once
# install.packages("raster")
# install.packages("neonUtilities")
# install.packages("devtools")
# 
# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
# library(devtools)
# install_github("NEONScience/NEON-geolocation/geoNEON")

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

# # Download data from portal via R
# options(stringsAsFactors = F)
# # download observational data with zipsByProduct() from the data portal remotely
# #Only have to do this step once (the first time you work the data)
#   #Birds (Need to create folder - see dirPaste() before running code)
# dirPaste <- paste(dir,'/Data/Birds', sep = "")
#   # dpID and savepath ae the only things that need to change
# zipsByProduct(dpID = "DP1.10003.001",   #DPI for Bird Point Count data, you get that from the Data Portal in-dev browser
#               site = 'all', #dont change
#               package = 'basic', #dont change
#               check.size = T, #dont change
#               savepath = dirPaste)
#   #After running this function, you need to type 'y' in the console, and hit enter
# #This script to download Bird data was run on 13 Nov 2018


# #now stack downloaded data
# dirPaste <- paste(dir,'/Data/Birds/filesToStack10003', sep = "") #10003 refers to the DPI
# stackByTable(dirPaste, folder = T) 
# This script to stack data was run on 27 Nov 2018

##
#### MAMMALS
##

# dirPasteM <- paste(dir,'/Data/Mammals', sep = "")
# zipsByProduct(dpID = "DP1.10072.001",   #DPI
#               site = 'all', #dont change
#               package = 'basic', #dont change
#               check.size = T, #dont change
#               savepath = dirPasteM)
# #This script to dowlnload Mamma data was run on 27 Nov 2018

# dirPasteM <- paste(dir,'/Data/Mammals/filesToStack10072', sep = "") #refers to the DPI
# stackByTable(dirPasteM, folder = T)
# #This script to stack Mammal data was run on 27 Nov 2018

##
#### BEETLES
##
# 
# dirPasteB <- paste(dir,'/Data/Beetles', sep = "")
# zipsByProduct(dpID = "DP1.10022.001",   #DPI
#               site = 'all', #dont change
#               package = 'basic', #dont change
#               check.size = T, #dont change
#               savepath = dirPasteB)
# This script to download Beetles data was run on 27 Nov 2018

# dirPasteM <- paste(dir,'/Data/Beetles/filesToStack10022', sep = "") #refers to the DPI
# stackByTable(dirPasteM, folder = T)
# #This script to stack Beetles data was run on 27 Nov 2018


#########
## PART - IMPORT DATA 
#########

##
#### BIRDS
##

# Read in Bird Data

#Count Data
birdCount <- read.delim(paste(dir, "/Data/Birds/filesToStack10003/stackedFiles/brd_countdata.csv", sep = ""), sep = ",")
#Repeat for points data
birdPoint <- read.delim(paste(dir, "/Data/Birds/filesToStack10003/stackedFiles/brd_perpoint.csv", sep = ""), sep = ",")


##
#### MAMMALS
##

mamPlot <- read.delim(paste(dir, "/Data/Mammals/filesToStack10072/stackedFiles/mam_perplotnight.csv", sep = ""), sep = ",")
mamTrap <- read.delim(paste(dir, "/Data/Mammals/filesToStack10072/stackedFiles/mam_pertrapnight.csv", sep = ""), sep = ",")

##
#### BEETLES
##

# #Not currently looking at beetle data right now


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


