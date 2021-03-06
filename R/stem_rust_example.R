#########################################################
## Predictive characterization of CWR and landraces    ##
## Focused Identification of Germplasm Strategy (FIGS) ##
#########################################################

# Demo example for predictive modeling of crop traits with environment layers.
# http://trait-mining.googlecode.com/svn/trunk/R/stem_rust_example.R

# This script was initiated at the PGR Secure workshop in Madrid, 10 January 2012.
# Script last updated 3 November 2014 by Dag Endresen.
# Contact email: dag.endresen@gmail.com
# Creative Commons Attribution 3.0 (CC-BY)
# http://creativecommons.org/licenses/by/3.0/

# This demo example uses a stem rust trait set available from USDA GRIN
# available at http://www.ars-grin.gov/cgi-bin/npgs/html/desc.pl?65049
# and environment layers from WorldClim, http://www.worldclim.org/current
# This is the same data set as explored by Endresen et al. (2011)
# http://dx.doi.org/doi:10.2135/cropsci2010.12.0717

# Included in a Bioversity technical guidelines, November 2014:
# Citation: Thormann I, Parra-Quijano M, Endresen DTF,  Rubio-Teso ML, 
#  Iriondo MJ, and Maxted N (2014). Predictive characterization of crop 
#  wild relatives and landraces. Technical guidelines version 1. 
#  Bioversity International, Rome, Italy. ISBN 978-92-9255-004-2.



#############################################
## Set working directory and read packages ##
#############################################

# Choose a directory to be your R workspace.
#setwd("C:/workspace/PGRSecure") # Example for a Windows PC
setwd("/Users/dag/workspace/r/pgrsecure") # Example for a bash shell (Linux, Mac)

# Note: Make sure you have installed these packages.
#install-packages(c("randomForest", "maps", "mapdata"))
#install-packages(c("raster", "dismo", "rgbif"))

require(randomForest) # random forest algorithm
library(maps) # we will use this R-package to plot a world map
library(mapdata) # we will use this R-package to plot a world map
#library(rgbif) # downloading occurrence records from GBIF
#library(raster) # spatial raster data management (and downloading WorldClim environment)
#library(dismo) # species distribution modeling tools


######################
## Read data into R ##
######################

# Download stem rust demo data set, this is a prepared exmple set
# with trait data from USDA GRIN: http://www.ars-grin.gov/cgi-bin/npgs/html/desc.pl?65049
# and environment layers from WorldClim: http://www.worldclim.org/current
# http://trait-mining.googlecode.com/svn/trunk/data/stemrust/stem_rust_set.txt
download.file("http://trait-mining.googlecode.com/svn/trunk/data/stemrust/stem_rust_set.txt", "./stem_rust/stem_rust_set.txt")

# Read the downloaded stem rust demo data set into R.
sr <- read.delim("./stem_rust/stem_rust_set.txt", header=TRUE, dec=".")


#####################################
## Plot occurrence points on a map ##
#####################################

# Using a world-map from the maps and mapdata R-package
map('world') # pkg maps

# Plot the stem rust collecting sites onto the map
points(sr[c("longitude","latitude")], col='red') # plot sr points to the map


##########################################################
## Prepare variables to use for the predictive modeling ##
##########################################################

# Read trait variable (s3) and bioclim climate data.
# "s3" has the stem rust trait scores reclassified to three levels:
# 1 = resistant, 2 = intermediate, and 3 = susceptible germplasm accessions.
Xbio <- sr[c("s3","bio1","bio2","bio3","bio4","bio5","bio6","bio7","bio8","bio9","bio10","bio11","bio12","bio13","bio14","bio15","bio16","bio17","bio18","bio19")]

# Pre-processing
# Autoscale = center around the mean, and divide by standard deviation.
# Autoscaling is a useful preprosessing approach giving each climate variable a more equal 
# influence on the calibration of the model irrespective of numeric values and variance.
scale(Xbio[,2:20], center=TRUE, scale=TRUE)

# Splitting the data set into training and test set.
# For this demo example we split 50% records to each set.
# An independent test set is highly recommended!!!
Xcal <- Xbio[1:3445,] # training set - for model calibration
Xtest <- Xbio[3446:6890,] # test set - to validate model performance


#######################
## Model calibration ##
#######################

# Calibrate model using the training set.
rf <- randomForest(as.factor(s3) ~ ., data=Xcal, ntr=50)
plot(rf) # preview of the model

# Read the confusion table from the model object.
conf <- rf$confusion
TP <- conf[1,1]
FP <- conf[2,1] + conf[3,1]
FN <- conf[1,2] + conf[1,3]
TN <- conf[2,2] + conf[2,3] + conf[3,2] + conf[3,3]

# Calculate calibration performance metrics (for the training set).
Sensitivity_cal <- TP/(TP + FN)
Specificity_cal <- TN/(TN + FP)
PO_cal <- (TP + TN)/sum(TP,FP,FN,TN) # proportion of observed agreement
PA_cal <- (2*TP)/(2*TP+FP+FN) # proportion of observed positive agreement
PPV_cal <- TP/(TP + FP) # positive predictive value 
LRpos_cal <- (TP/(TP + FN)/(FP/(FP+TN))) # positive diagnostic likelihood ratio


###############################
## Prediction based on model ##
###############################

# Predict scores for the test set
prediction <- predict(rf, Xtest) # pkg stats, randomForest
plot(prediction) # preview classification results
hist(Xtest$s3) # preview classification histogram
#print(prediction) #transform(prediction) #transform(Xtest$s3)

# Evaluation of prediction metrics
# with lower and upper 95% confidence interval boundaries
# TP = true positives, FP = false positives
# TN = true negatives, FN = false negatives

# read the confusion table from the prediction object
conf <- table(Xtest$s3, prediction)
TP <- conf[1,1]
FP <- conf[2,1] + conf[3,1]
FN <- conf[1,2] + conf[1,3]
TN <- conf[2,2] + conf[2,3] + conf[3,2] + conf[3,3]

# z is a measure of standard deviation for the statistical significance test
z = 1.959964 # 95% confidence interval

Sensitivity_test <- TP/(TP + FN)
Sensitivity_test_lower <- ((2*TP)+z*2-z*sqrt((4*TP*FN/(TP+FN))+z*2))/((2*(TP+FN))+(2*z*2))
Sensitivity_test_upper <- ((2*TP)+z*2+z*sqrt((4*TP*FN/(TP+FN))+z*2))/((2*(TP+FN))+(2*z*2))

Specificity_test <- TN/(FP + TN)
Specificity_test_lower <- ((2*TN)+z*2-z*sqrt((4*TN*FP/(FP+TN))+z*2))/((2*(FP+TN))+(2*z*2))
Specificity_test_upper <- ((2*TN)+z*2+z*sqrt((4*TN*FP/(FP+TN))+z*2))/((2*(FP+TN))+(2*z*2))

PPV_test <- TP/(TP + FP) # positive predictive value
PPV_test_lower <- ((2*TP) + z*2 - z*sqrt((4*TP*FP/(TP+FP)) + z*2)) / ((2*(TP+FP)) + (2*z*2))
PPV_test_upper <- ((2*TP) + z*2 + z*sqrt((4*TP*FP/(TP+FP)) + z*2)) / ((2*(TP+FP)) + (2*z*2))

#LRpos_test <- Sensitivity_test / (1-Specificity_test)
LRpos_test <- (TP/(TP + FN)/(FP/(FP+TN))) # positive diagnostic likelihood ratio
LRpos_test_lower <- exp(log(((FP+TN)*TP)/((TP+FN)*FP))-z*sqrt((FN/(TP*(TP+FN)))+(TN/(FP*(FP+TN)))))
LRpos_test_upper <- exp(log(((FP+TN)*TP)/((TP+FN)*FP))+z*sqrt((FN/(TP*(TP+FN)))+(TN/(FP*(FP+TN)))))

PO_test <- (TP + TN)/sum(TP,FP,FN,TN) # proportion of observed agreement
PA_test <- (2*TP)/(2*TP+FP+FN) # proportion of observed positive agreement


#####################################################
## FINAL prediction for accession not yet screened ##
#####################################################

# Final step: predictions for accessions with unknown trait scores.
# Extract the exact same environmental layers for these accessions.
# Note, exact same environment columns as used for the training set.
#Xpred <- your_new_prediction_data_set_here

# You might first want to prepare a new model including ALL the records in the stem rust demo set.
# ... all the data records that you have access to with trait information.
#rf <- randomForest(as.factor(s3) ~ ., data=Xbio, ntr=50)


# The example below will use the 19 BioClim variables

# Tab-delimited pred_accessions input with columns "longitude" and "latitude" 
pred <- read.delim("./YOUR_PATH/pred_accessions.txt", header=TRUE, dec=".") 
xy_pred <- pred[c("longitude","latitude")]

# WorldClim, http://www.worldclim.org/ (See also CODE BOX 4.1)
env <- getData('worldclim', var='bio', res=10)
Xpred <- extract(env, xy_pred); # extract environment to points (pkg raster)

# Predict scores for the new set
prediction <- predict(rf, Xpred) # pkg stats

table(prediction) # how many predicted to each class

# Note that the real measured trait scores are not available here, and prediction
# metrics can thus not be calculated (before after the final field trials are made).



