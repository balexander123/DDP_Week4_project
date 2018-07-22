# Golbal environment contains information needed in both the ui and server scripts
# Lines 3-6 should be in all global.R scripts for shiny/plotly Apps
library(plotly)
library(shiny)
library(dplyr)

py <- plot_ly(username="rAPI", key="yu680v5eii")

source("plotlyGraphWidget.R")

# User Specific information:
# Load data
## In this example, data is used in both the ui and server scripts
Ideal_Point_Data <- read.csv("Data/UN_IdealPoints.csv", stringsAsFactors=F)

Storm_Data <- read_csv(file="data/StormEvents_details-ftp_v1.0_d2018_c20180618.csv")

# Clean up Storm_Data and compute multipliers for ecomomic damage as dollar amounts

# Process economic damage
Storm_Data$DAMAGE_PROPERTY[is.na(Storm_Data$DAMAGE_PROPERTY)] <- "0.00K" # remove NAs
exp_pattern <- '[a-zA-Z]'
Storm_Data$DAMAGE_PROPERTYEXP <- str_extract(Storm_Data$DAMAGE_PROPERTY, exp_pattern)
Storm_Data$DAMAGE_PROPERTYEXP <- as.factor(Storm_Data$DAMAGE_PROPERTYEXP)
PROPERTYEXP <- levels(Storm_Data$DAMAGE_PROPERTYEXP)
pMultiplier <- c(1000,1000000)
propLookup  <- data.frame(cbind(PROPERTYEXP,pMultiplier))
propLookup$pMultiplier <- as.numeric(as.character(propLookup$pMultiplier))
Storm_Data <- merge(Storm_Data,propLookup)
Storm_Data$DAMAGE_PROPERTYNUM <- as.numeric(str_extract(Storm_Data$DAMAGE_PROPERTY, "\\d+\\.*\\d*"))
Storm_Data$totalPropDamage <- Storm_Data$DAMAGE_PROPERTYNUM*Storm_Data$pMultiplier

Storm_Data$DAMAGE_CROPS[is.na(Storm_Data$DAMAGE_CROPS)] <- "0.00K" # remove NAs
Storm_Data$DAMAGE_CROPSEXP <- str_extract(Storm_Data$DAMAGE_CROPS, exp_pattern)
Storm_Data$DAMAGE_CROPSEXP <- as.factor(Storm_Data$DAMAGE_CROPSEXP)
CROPEXP <- levels(Storm_Data$DAMAGE_CROPSEXP)
pMultiplier <- c(1000,1000000)
propLookup  <- data.frame(cbind(CROPEXP,pMultiplier))
propLookup$pMultiplier <- as.numeric(as.character(propLookup$pMultiplier))
Storm_Data <- merge(Storm_Data,propLookup)
Storm_Data$DAMAGE_CROPNUM <- as.numeric(str_extract(Storm_Data$DAMAGE_CROPS, "\\d+\\.*\\d*"))
Storm_Data$totalCropDamage <- Storm_Data$DAMAGE_CROPNUM*Storm_Data$pMultiplier
Storm_Data$totalDamage <- Storm_Data$totalPropDamage + Storm_Data$totalCropDamage
