library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)
library(quantmod)
####################################################################################################
# wybiera zadane salary z ramki danych salary
# i zwraca ramkę danych z widełkami dla każdego rodzaju umowy w osobnej kolumnie
SalaryContract <- function(salary_col_num, salary) {
  salary_x <- salary[, salary_col_num] %>%
    stri_split(fixed = "\n", simplify = T) %>%
    as.data.frame()

  salary_x[, 3] <- salary_x[, 2] %>%
    stri_extract_all(regex = "miesiecznie|dziennie|godzinowo") %>%
    unlist()
  salary_x[, 2] <- salary_x[, 2] %>%
    stri_extract_all(regex = "B2B|UZ|UoP|UoD") %>%
    unlist()

  B2B <- ifelse(salary_x$V2 == "B2B", paste0(salary_x$V1, "|", salary_x$V3), NA)
  UoP <- ifelse(salary_x$V2 == "UoP", paste0(salary_x$V1, "|", salary_x$V3), NA)
  UZ <- ifelse(salary_x$V2 == "UZ", paste0(salary_x$V1, "|", salary_x$V3), NA)
  UoD <- ifelse(salary_x$V2 == "UoD", paste0(salary_x$V1, "|", salary_x$V3), NA)



  salary_x <- data_frame(B2B, UoP, UZ, UoD)
  return(salary_x)
}

####################################################################################################
# Przewalutowanie płac
ConversionToPLN <- function(Price, Currency, Period) {
  converted <- c(rep(NA, length(Currency)))
  # Ściąganie danych z internetu opóźnia funkcje, zdaję sobie z tego sprawę dlatego podaje stałe wartości zamiennie
  # GBPtoPLN <- 5.45582
  # EURtoPLN <- 4.6832
  # HUFtoPLN <- 0.01394995
  # USDtoPLN <- 4.47795
  # CHFtoPLN <- 4.6085
  # CZKtoPLN <- 0.1892
  # UAHtoPLN <- 0.15

  GBPtoPLN <- getQuote(paste0("GBP", "PLN", "=X"))$Last
  EURtoPLN <- getQuote(paste0("EUR", "PLN", "=X"))$Last
  HUFtoPLN <- getQuote(paste0("HUF", "PLN", "=X"))$Last
  USDtoPLN <- getQuote(paste0("USD", "PLN", "=X"))$Last
  CHFtoPLN <- getQuote(paste0("CHF", "PLN", "=X"))$Last
  CZKtoPLN <- getQuote(paste0("CZK", "PLN", "=X"))$Last
  # Hrywna nie jest dostępna w Yahoo finance
  UAHtoPLN <- getQuote(paste0("UAH", "USD", "=X"))$Last * getQuote(paste0("USD", "PLN", "=X"))$Last

  for (i in seq_along(Currency)) {
    price_i <- Price[i]
    if (is.na(Currency[i]) == FALSE & is.na(price_i) == FALSE & is.na(Period[i]) == FALSE) {
      converted[i] <- switch(Currency[i],
        "GBP" = round(price_i * GBPtoPLN, 0),
        "EUR" = round(price_i * EURtoPLN, 0),
        "HUF" = round(price_i * HUFtoPLN, 0),
        "USD" = round(price_i * USDtoPLN, 0),
        "CHF" = round(price_i * CHFtoPLN, 0),
        "CZK" = round(price_i * CZKtoPLN, 0),
        "UAH" = round(price_i * UAHtoPLN, 0),
        "PLN" = price_i
      )

      if (Period[i] == "dziennie") {
        converted[i] <- converted[i] * 20
      }
      if (Period[i] == "godzinowo") {
        converted[i] <- converted[i] * 160
      }
    }
  }
  return(converted)
}

####################################################################################################
# uzyskanie właściwych pól salary, przewalutowanych oraz z podziałem na Min i Max dla każdego typu umowy
GetRightSalary <- function(salary_1) {

  # stworzenie wektora z walutami
  currency <- salary_1 %>%
    stri_extract_all(regex = "\\p{Lu}\\p{Lu}\\p{Lu}") %>%
    unlist()
  # Wyznaczenie okresu
  period <- salary_1 %>%
    stri_extract_all(regex = "miesiecznie|dziennie|godzinowo") %>%
    unlist()

  # Rozdzielenie widełek płacowych
  salaryRange <- salary_1 %>%
    stri_extract_all(regex = "(\\P{L}+) - (\\P{L}+)", simplify = T) %>%
    stri_split(fixed = "-", simplify = T)
  # przypisanie widełek oraz waluty i okresu płacy
  salaryRangeMin <- salaryRange[, 1] %>%
    stri_replace_all(regex = "\\s", "") %>%
    as.numeric()
  salaryRangeMax <- salaryRange[, 2] %>%
    stri_replace_all(regex = "\\s", "") %>%
    as.numeric()

  salaryRangeMinConv <- ConversionToPLN(salaryRangeMin, currency, period)
  salaryRangeMaxConv <- ConversionToPLN(salaryRangeMax, currency, period)

  RightSalary <- data.frame(salaryRangeMinConv, salaryRangeMaxConv)

  return(RightSalary)
}

# Funkcja która tworzy rozdziela kolumnę requirements na kolumny logiczne za pomocą funckji
# map dla danej umiejętności, w zależności czy jest ona wymagana w danej ofercie. Zostały wybrane
# wymagania, które pojawiają się w przynajmniej 10% ofert.
CleaningRequirements <- function (requirements){
  req <- stri_split(requirements, fixed = "|") %>% map(stri_trans_tolower)

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


belong <- map(req, ~ 1 * (reqUniq %in% .x))

dfReq <- do.call(rbind, belong)

colnames(dfReq) <- reqName

return(dfReq)
}

#Funkcja która ściąga zawartość podanych w katalogu ofert i zapisuje do pliku
# .CSV("offers_noFluffJobs_aktualna_data"), funkcja może wymagać aktualnego katalogu ofert uzyskanego
# za pomocą funcji GETurls

GETcontent <- function (urlsCatalog){
# zmiana nazwy agenta
set_config(add_headers("User-Agent" = "Mozilla/5.0"))

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

        # przypisanie ramki danych do zmiennej
        final_df <- df %>% rowwise() %>%  mutate_if(is.list, ~ paste(unlist(.), collapse = "|"))

        # zapis do pliku csv
        write.csv2(final_df ,file = paste0("offers_noFluffJobs_", format(Sys.time(), "%x_%X"), ".csv"),
                       row.names = FALSE)
    }
}
return(final_df)
}

#Funcja tworzy katalog na podstawie stron wyszukiwania. Jako argumenty należy podać bazowy link
# url wyszukiwania i liczbę stron wyszukiwania z której mają być ściągnięte linki do konkretnych
# ofert. Na jednej stronie wyszukiwania występuję około 20 ofert. Katalog jest zwracany oraz eksportowany do pliku
# CSV.  ("urlsList_aktualna_data")
GETurls <- function (urlBase, numberOfPages){

# zmiana nazwy agenta
set_config(add_headers("User-Agent" = "Mozilla/5.0"))

# utworzenie katalogu linków URL do kolejnych stron wyszukiwać pracy zdalnej
# UWAGA: ilość linków jest zmienna, być może drugi parametr wymaga modyfikacji!!

urlsCatalog_1 <- paste0(urlBase, 1:numberOfPages)

# deklaracja zmiennych jako puste listy
urlsList <- list()


# wyciągniecię z calatol_url i wprowadzanie URL-ów do urlsList(listy)
for (i in seq_along(urlsCatalog_1)) {

  # pobranie strony funkcją GET
  dataGET <- GET(urlsCatalog_1[i])

  # przypisane zawartości xml strony do zmiennej
  data <- content(dataGET)

  #
  tryCatch(url <- data %>%
    html_elements("a.posting-list-item") %>% html_attr("href"),
  error = function(e) {
    print(e)
    "NA"
  }
  )


  # złączenie linku w całość, stworzenie poprawnego URL
  url <- paste0("https://nofluffjobs.com", url)

  # wczytywanie adresów z katalogu do listy
  urlsList[[i]] <- url

  # opóźnienie iteracji
  Sys.sleep(1)
  time <- format(Sys.time(), "%X")
  print(paste0("Iteration: ", i, " | Time: ", time))

  # końcowe informacje
  if (i == length(urlsCatalog_1)) {
    print("Successful finish :D")
    finalList <- urlsList %>% unlist() %>% unique()
    write_lines(finalList,
      file = paste0("urlsList_", format(Sys.time(), "%x_%X"), ".csv")
    )
  }
}
    return(finalList)
}