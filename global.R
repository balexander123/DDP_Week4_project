# Golbal environment contains information needed in both the ui and server scripts

library(plotly)
library(shiny)
library(dplyr)
library(readr)
library(stringr)
library(R.utils)  # bunzip2d

# User Specific information:
# Load data

if(!file.exists("data")){dir.create("data")}

stormDestFile <- "data/StormEvents_details-ftp_v1.0_d2017_c20180718.csv"

if(!file.exists(stormDestFile)) {
  fileUrl <- "https://www1.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/StormEvents_details-ftp_v1.0_d2017_c20180718.csv.gz"
  download.file(fileUrl,destfile="data/StormEvents_details-ftp_v1.0_d2017_c20180718.csv.gz",method="curl")
  gunzip("data/StormEvents_details-ftp_v1.0_d2017_c20180718.csv.gz")
}

Storm_Data <- read_csv(file="data/StormEvents_details-ftp_v1.0_d2017_c20180718.csv")

# Clean up Storm_Data and compute multipliers for ecomomic damage as dollar amounts

# Process economic damage
Storm_Data$DAMAGE_PROPERTY[is.na(Storm_Data$DAMAGE_PROPERTY)] <- "0.00K" # remove NAs
exp_pattern <- '[a-zA-Z]'
Storm_Data$DAMAGE_PROPERTYEXP <- str_extract(Storm_Data$DAMAGE_PROPERTY, exp_pattern)
Storm_Data$DAMAGE_PROPERTYEXP <- as.factor(Storm_Data$DAMAGE_PROPERTYEXP)
PROPERTYEXP <- levels(Storm_Data$DAMAGE_PROPERTYEXP)
pMultiplier <- c(10000000,1000,1000000)
propLookup  <- data.frame(cbind(PROPERTYEXP,pMultiplier))
propLookup$pMultiplier <- as.numeric(as.character(propLookup$pMultiplier))
Storm_Data <- merge(Storm_Data,propLookup)
Storm_Data$DAMAGE_PROPERTYNUM <- as.numeric(str_extract(Storm_Data$DAMAGE_PROPERTY, "\\d+\\.*\\d*"))
Storm_Data$totalPropDamage <- Storm_Data$DAMAGE_PROPERTYNUM*Storm_Data$pMultiplier

Storm_Data$DAMAGE_CROPS[is.na(Storm_Data$DAMAGE_CROPS)] <- "0.00K" # remove NAs
Storm_Data$DAMAGE_CROPSEXP <- str_extract(Storm_Data$DAMAGE_CROPS, exp_pattern)
Storm_Data$DAMAGE_CROPSEXP <- as.factor(Storm_Data$DAMAGE_CROPSEXP)
CROPEXP <- levels(Storm_Data$DAMAGE_CROPSEXP)
pMultiplier <- c(10000000,1000,1000000)
propLookup  <- data.frame(cbind(CROPEXP,pMultiplier))
propLookup$pMultiplier <- as.numeric(as.character(propLookup$pMultiplier))
Storm_Data <- merge(Storm_Data,propLookup)
Storm_Data$DAMAGE_CROPNUM <- as.numeric(str_extract(Storm_Data$DAMAGE_CROPS, "\\d+\\.*\\d*"))
Storm_Data$totalCropDamage <- Storm_Data$DAMAGE_CROPNUM*Storm_Data$pMultiplier
Storm_Data$totalDamage <- Storm_Data$totalPropDamage + Storm_Data$totalCropDamage
