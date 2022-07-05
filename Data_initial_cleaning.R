library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)

# PODSTAWIĆ ODPOWIEDNI LINK
df <- read.csv2("Original_dataset.csv")
####################################################################################################
# zmiana nazwy kolumny urlsCatalog
df <- rename(df, url = urlsCatalog)

# usunięcie bezpłatnych ofert stażowych
bezplatny <- df$salary == "bezpłatny\n\nstaż"
df <- df[!bezplatny, ]

# wybranie unikatowych ofert
df <- (df[!duplicated(df[, c(1:6)]), ])
####################################################################################################
# zastąpienie kolumny title_company przez company
title_company <- df$title_company %>% stri_split(fixed = "\n", simplify = T)
df <- df %>% add_column(company = title_company[, 2], .before = "category")
df$title_company <- NULL

####################################################################################################
# zastąpienie kolumny category przez position
category <- df$category %>% stri_split(fixed = ", ", simplify = T)
df <- df %>% add_column(
  position = category[, 1],
  .before = "level"
)
df$category <- NULL

####################################################################################################
# nadpisanie kolumny level
level <- df$level %>% stri_split(fixed = ", ", simplify = T)
df$level <- NULL
df <- df %>% add_column(
  level = level[, 1],
  .before = "requirements"
)
####################################################################################################
#usunięcie polskich znaków z kolumny salary
df$salary <- df$salary %>% stri_trans_general("Latin-ASCII")

####################################################################################################
write.csv2(df, "catalog_noFluffJobs_initially_cleaned.csv", row.names = F)
