library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)
#####################

urlsCatalog <- GETurls("https://nofluffjobs.com/pl/praca-zdalna?criteria=city%3Dwarszawa,krakow,wroclaw,gdansk,poznan,trojmiasto,katowice,slask,lodz,bialystok,gdynia,lublin,rzeszow,bydgoszcz,gliwice,czestochowa,szczecin,sopot&page=", 1)

df1 <- GETcontent(urlsCatalog)