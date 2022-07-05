library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)

# PODSTAWIĆ ODPOWIEDNI LINK
df <- read.csv2("catalog_noFluffJobs_initially_cleaned.csv")

# unikatowa lista wymagań
req <- stri_split(df$requirements, fixed = "|") %>% map(stri_trans_tolower)

# wybieram najczęściej powtarzające się requirements(tylko te które powtarzają się 38 i więcej razy)
reqTable <- req %>%
  unlist() %>%
  table() %>%
  sort.default(decreasing = T) %>%
  as.data.frame()

reqUniq <- reqTable$.[reqTable[, 2] > 37] %>% as.character()



reqName <- reqUniq %>%
  unlist() %>%
  stri_trans_general("Latin-ASCII") %>%
  stri_replace_all("_", regex = "\\s+")


reqLabels <- data.frame(requirement = reqName, LabelRequirement = reqUniq)

belong <- map(req, ~ 1 * (reqUniq %in% .x))

dfReq <- do.call(rbind, belong)

colnames(dfReq) <- reqName
####################################################################################################
write.csv2(dfReq, "Cleaned_requirements.csv", row.names = F)
