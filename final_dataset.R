library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)
####################################################################################################
df <- read.csv2("Initially_cleaned.csv")
df1 <- read.csv2("Cleaned_salary.csv")

df2 <- Cleaning_requirements(df$requirements)

df <- cbind(df1,df2)
df$requirements <- NULL

write.csv2(df, "Final_dataset.csv",path=  row.names = F)
