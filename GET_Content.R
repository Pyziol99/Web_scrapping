library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)
# zmiana nazwy agenta
set_config(add_headers("User-Agent" = "Mozilla/5.0"))

# ZAŁADOWAĆ WŁAŚCIWY PLIK
urlsCatalog <- readLines("urlsList_04.06.2022_14:15:48.csv")

# deklaracja zmiennych jako puste listy
title_company <- character()
category <- character()
requirements <- list()
level <- character()
salary <- list()

# wyciągniecię z calatol_url i wprowadzanie URL-ów do urls_list(listy)
for (i in seq_along(urlsCatalog)) {
    data_get <- GET(urlsCatalog[i])
    data <- content(data_get)
    
    # Title
    tryCatch(
        title_company[i] <- data %>% html_elements(".justify-content-lg-start") %>% html_text2(),
        error = function(e) {
            print(e)
            NA
        }
    )
    
    # category
    tryCatch(
        category[i] <- data %>% html_elements("common-posting-cat-tech") %>%
            html_elements(".font-weight-semi-bold") %>% html_text2(),
        error = function(e) {
            print(e)
            NA
        }
    )
    
    # Requirements
    tryCatch(
        requirements[[i]] <- data %>% html_elements(".d-block:nth-child(1)") %>%
            html_elements("common-posting-item-tag") %>% html_text2(),
        error = function(e) {
            print(e)
            NA
        }
    )
    
    # Seniority level
    tryCatch(
        level[i] <- data %>% html_elements("common-posting-seniority") %>% html_text2(),
        error = function(e) {
            print(e)
            NA
        }
    )
  
    # Salary .type , .salary .mb-0
    tryCatch(
        salary[[i]] <- data %>% html_elements(".salary") %>% html_text2(),
        error = function(e) {
            print(e)
            NA
        }
    )
    
    
    # opóźnienie iteracji
    Sys.sleep(1)
    time <- format(Sys.time(), "%X")
    print(paste0("Iteration: ", i, " | Time: ", time))
    
    if (i == length(urlsCatalog)) {
        print("Successful end :D")
        
        # wprowdzanie wektorów do ramki danych
        df <- data_frame(title_company, category, level, requirements, salary, urlsCatalog)
        
        # zapis do pliku csv
        df %>%
            rowwise() %>%
            mutate_if(is.list, ~ paste(unlist(.), collapse = "|")) %>%
            write.csv2(file = paste0("offers_noFluffJobs_", format(Sys.time(), "%x_%X"), ".csv"), row.names = FALSE)
    }
}
