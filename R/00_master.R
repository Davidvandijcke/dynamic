
#****************************************************************************************************************************************************

# MASTER SCRIPT: Firm Entry and Competition with Local Labor Markets

#****************************************************************************************************************************************************


#### SET OVERALL PARAMETERS ####

#### SET PATHS ####

if (!require("here", character.only=T)) {install.packages("here", dependencies=TRUE)}; require("here")
codeDir <- dirname(here::here())
setwd(codeDir) # sets cd to program directory

dir <- dirname(codeDir) # get main directory
data_dir <- file.path(dir, "data")
results_dir <- "/Users/davidvandijcke/Dropbox (University of Michigan)/Apps/Overleaf/dynamic/results"
tabs <- file.path(results_dir, "tabs")
figs <- file.path(results_dir, "figs")



#### USER-WRITTEN FUNCTIONS ####


#### LOAD LIBRARIES AND OTHER REQS ####
source("00_prep.R")

# rgdal, spdep, sf, tigris, tmap


#### GET DATA FROM AWS, CONSTRUCT GRAPHS, COMPILE ####
#source("10_getRawData.R")


#### PROCESS RAW DATA INTO ANALYSIS-READY DATASETS ####
#source("11_processData.R")
