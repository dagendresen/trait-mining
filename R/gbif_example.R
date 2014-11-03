###########################################
## Download occurrence records from GBIF ##
###########################################

# Demo example used for predictive modeling of crop traits with environment layers.
# http://trait-mining.googlecode.com/svn/trunk/R/gbif_example.R

# This script was created in October 2014.
# Script last updated 3 November 2014 by Dag Endresen.
# Contact email: dag.endresen@gmail.com
# Creative Commons Attribution 3.0 (CC-BY)
# http://creativecommons.org/licenses/by/3.0/

# Included in a Bioversity technical guidelines, November 2014:
# Citation: Thormann I, Parra-Quijano M, Endresen DTF,  Rubio-Teso ML, 
#  Iriondo MJ, and Maxted N (2014). Predictive characterization of crop 
#  wild relatives and landraces. Technical guidelines version 1. 
#  Bioversity International, Rome, Italy. ISBN 978-92-9255-004-2.


#############################################
## Set working directory and read packages ##
#############################################

# Choose a directory to be your R workspace.
#setwd("C:/workspace/gbif") # Example for a Windows PC
setwd("/Users/dag/workspace/r/gbif") # Example for a bash shell (Linux, Mac)

# Note: Make sure you have installed these packages.
#install-packages("rgbif")
#install-packages(c("maps", "mapdata"))
#install-packages(c("raster", "dismo")

require(rgbif) # downloading occurrence records from GBIF
library(maps) # we will use this R-package to plot a world map
library(raster) # spatial raster data management (and downloading WorldClim environment)
#library(dismo) # species distribution modeling tools
## NB! gbif download in dismo is broken and will attemp to download from the old GBIF portal
## The old pre-2013 GBIF portal was replaced in October 2013. 
## The old portal is not updated with new records.


####################################
## Download occurrences from GBIF ##
####################################

# GBIF, http://www.gbif.org # rgbif, http://cran.r-project.org/package=rgbif
key <- name_backbone(name='Beta vulgaris')$speciesKey # taxonKey=5383920

# Example here is limited to 1000 (maximum limit in rgbif is 1 million records per search)
bv <- occ_search(taxonKey=key, return='data', hasCoordinate=TRUE, limit=1000)

# Example of renaming columns
xy <- cbind('species'=bv$name, 'lon'=bv$decimalLongitude, 'lat'=bv$decimalLatitude);

# You may want to check the occurrence data downloaded from GBIF for duplicates 
# and/or combine the occurrences with data from other sources.

# Uncomment the line below to write your occurrence data to a tab-delimited file 
# write.table(xy, file="bv_set.txt", sep="\t", col.names=NA, qmethod="double")

# Uncomment the line below to read corrected occurrence data back into R 
# xy <- read.delim("./YOUR_PATH/bv_set.txt", header=TRUE, dec=".")

map('world') # R-package: maps and mapdata 
points (xy$lon, xy$lat, col='red') # plot points


############################################################
## Download and extract environment layers from WorldClim ##
############################################################

# WorldClim, http://www.worldclim.org/
env <- getData('worldclim', var='bio', res=10) # (pkg raster)
Xbio <- extract(env, xy); # extract environment to points (pkg raster)
plot(env, 1) # plot the first bioclim layer


###################################################
## Plot occurrence points again on a bioclim map ##
###################################################

points (xy$lon, xy$lat, col='red') # plot points onto bioclim map
