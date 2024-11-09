#1. Read in data files
library(tidyverse)
GII2010<- read.csv("/Users/mac/Desktop/MSc Urban Spatial Science/CASA0005/W4/CASA0005_W4_HOMEWORK PROJECT/GII2010.csv")
GII2019<- read.csv("/Users/mac/Desktop/MSc Urban Spatial Science/CASA0005/W4/CASA0005_W4_HOMEWORK PROJECT/GII2019.csv")

#1a. Adding sources so that it can be reproducible in another device
GII_2010_209 <- read_csv("https://hdr.undp.org/sites/default/files/2023-24_HDR/HDR23-24_Composite_indices_complete_time_series.csv",
         locale = locale(encoding = "latin1"),
         na = "n/a")

library(sf)
WorldMap<- st_read("/Users/mac/Desktop/MSc Urban Spatial Science/CASA0005/W4/CASA0005_W4_HOMEWORK PROJECT/World_Countries_(Generalized)_9029012925078512962.geojson")

#2. Data pre-processing
INDEX2010<-GII2010[,c(1,2,3,9,10)] #Drop redundant columns
INDEX2019<-GII2019[,c(1,2,3,9,10)] #Drop redundant columns
library(dplyr)
colnames(INDEX2010)[4] <- "2010value" #Change column name
colnames(INDEX2019)[4] <- "2019value" #Change column name
INDEXCOMBINED <- left_join(INDEX2010,INDEX2019,by="country") #Join the two data frames by "country"
INDEXCOMBINED <- INDEXCOMBINED[,c(1,2,4,7)] #Drop redundant columns
install.packages('countrycode')
library(countrycode)
WorldMap["iso3"] <- countrycode(WorldMap$ISO, origin="iso2c", destination="iso3c") #Unify country code between the spatial file and the table

#3. Data joining
WorldGIIMap <- WorldMap %>%
  left_join(., INDEXCOMBINED, by = c("iso3" = "countryIsoCode.x")) #Join by the country code
cleaned_WorldGIIMap <- na.omit(WorldGIIMap) #Drop rows with null values
cleaned_WorldGIIMap <- cleaned_WorldGIIMap[,c(1,2,6,8,9)] #Drop redundant columns
cleaned_WorldGIIMap <- cleaned_WorldGIIMap %>% #Calculate the difference as the new variable
  mutate(diff = `2019value` - `2010value`) #Use backsticks (``),rather than single quotes ('') if column name starts with numbers

#4. Plot
library(tmap)
library(tmaptools)  
library(ggplot2)
tmap_mode("plot")
qtm(cleaned_WorldGIIMap, fill = "diff")
