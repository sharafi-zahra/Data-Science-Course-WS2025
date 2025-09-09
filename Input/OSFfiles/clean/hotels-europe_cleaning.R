#########################################################################################
# Prepared for Gabor's Data Analysis
#
# Data Analysis for Business, Economics, and Policy
# by Gabor Bekes and  Gabor Kezdi
# Cambridge University Press 2021
#
# gabors-data-analysis.com 
#
# License: Free to share, modify and use for educational purposes. 
# 	Not to be used for commercial purposes.
# version 1.1 2021-05-16
#########################################################################################

#############################################
#
# hotels-eruope cleaning
# input:
# hotelbookingdata.csv

# output:
# hotel-europe_prices.csv
# hotel-europe_features.csv

#############################################

# Clear memory
rm(list=ls())

# set working directory for data_repo
setwd("/Users/vigadam/Dropbox/work/data_book/da_data_repo/")

#location folders
data_in <- "hotels-europe/raw/"
data_out <- "hotels-europe/clean/"

# PACKAGES
library(dplyr)

### IMPORT AND PREPARE DATA

# variables downoaded as string, often in form that is not helpful
# need to transform then to numbers that we can use

df <- read.csv(paste0(data_in,"hotelbookingdata.csv"), stringsAsFactors = F)

# generate numerical variable of rating variable from string variable
#  trick: remove non-numeric characters using regex

# distance to center entered as string in miles with one decimal
df$distance <- as.numeric(gsub("[^0-9\\.]","",df$center1distance))
df$distance_alter <- as.numeric(gsub("[^0-9\\.]","",df$center2distance))

# parsing accommodationtype column
# replace missing values to handle split
df[df$accommodationtype == "_ACCOM_TYPE@",]$accommodationtype <- "_ACCOM_TYPE@NA"
df$accommodation_type <- unlist(sapply(strsplit(as.character(df$accommodationtype), "@"), '[[', 2))
df$accommodationtype <- NULL

# number of nights variable
df$nnights <- 1
df[df$price_night == "price for 4 nights",]$nnights <- 4

# ratings
# generate numerical variable of rating variable from string variable
# remove /5

df$rating <- as.numeric(gsub("/5","",df$guestreviewsrating))

# check: frequency table of all values
table(df$rating)

# RENAME VARIABLES
#colnames(df)[colnames(df)=="rating_reviewcount"] <- "rating_count"
colnames(df)[colnames(df)=="rating2_ta"] <- "ratingta"
colnames(df)[colnames(df)=="rating2_ta_reviewcount"] <- "ratingta_count"
colnames(df)[colnames(df)=="addresscountryname"] <- "country"
colnames(df)[colnames(df)=="s_city"] <- "city"

# look at key vars
colnames(df)[colnames(df)=="starrating"] <- "stars"
table(df$stars)
df$stars[df$stars == 0] <- NA

table(df$rating)

# drop if hotel id is missing
df <- df[!is.na(df$hotel_id), ]

# drop vars
df$center2distance <-  NULL
df$center1distance <-  NULL
df$price_night <- NULL
df$guestreviewsrating <- NULL

# DROP PERFECT DUPLICATES
df[duplicated(df)==T,]
#these are perfect duplicates of the observation in the previous row
df <- df[!duplicated(df), ]

df <- df %>%
  select(hotel_id, city, distance, stars, rating, year, month, weekend, holiday, everything())

# drop if the row is the same based on the most important variables
df <- df[!duplicated(subset(df, select = c(city, hotel_id, distance, stars, rating, price, year, month, weekend, holiday))), ]

# understand the structure of the dataset
# 1. date specific price
# 2. hotel features, location etc
# key is hotel_id

# hotel prices
data <- subset(df, select = c(hotel_id, price, offer, offer_cat, year, month, weekend, holiday, nnights, scarce_room))

# check if no duplicates
data <- data %>%
  mutate(a = group_indices_(data, .dots=c("hotel_id", "year", "month", "weekend", "holiday", "nnights")))
data <- data[!is.na(data$hotel_id) | !is.na(data$price),]
data$a <- NULL
write.csv(data, paste0(data_out,"hotels-europe_price.csv"), row.names = F)

data <- subset(df, select = -c(price, offer, offer_cat, year, month, weekend, holiday, nnights, scarce_room))
data <- data[!duplicated(data), ]

# there is something weird. need investigate #
data <- data %>%
  arrange(hotel_id)
data$l <- ifelse(data$hotel_id==lag(data$hotel_id, n = 1) | data$hotel_id==lead(data$hotel_id, n = 1), 1, 0)
data <- data %>%
  arrange(l, hotel_id)

# it turns out some hotel is featured w distance to two labels
data <- data[data$hotel_id!=lag(data$hotel_id, n = 1),]
data$l <- NULL
write.csv(data, paste0(data_out,"hotels-europe_features.csv"), row.names = F)
