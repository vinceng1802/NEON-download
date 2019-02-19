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

dir <- getwd()
setwd(dir)

##
#### INSTALL PACKAGES
##

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
mammals <- as.character(unzip("Mammals.zip", list = TRUE)$Name)
# LOAD PLOT DATA
mamPlot <- read.csv(unz("Mammals.zip", "Mammals/mam_perplotnight.csv"), header = TRUE,
                          sep = ",") 
# LOAD TRAP DATA
mamTrap <- read.csv(unz("Mammals.zip", "Mammals/mam_pertrapnight.csv"), header = TRUE,
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
mergedSites <- merge(x = newFieldSites, y = newMamPlot, 
                     by.x = "Site.ID", by.y = "siteID", all = TRUE)
unique(mergedSites[,1:3])