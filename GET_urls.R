library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)

# zmiana nazwy agenta
set_config(add_headers("User-Agent" = "Mozilla/5.0"))

# utworzenie katalogu linków URL do kolejnych stron wyszukiwać pracy zdalnej
# UWAGA: ilość linków jest zmienna, być może drugi parametr wymaga modyfikacji!!

urlsCatalog_1 <- paste0(
  "https://nofluffjobs.com/pl/praca-zdalna?criteria=city%3Dwarszawa,krakow,wroclaw,gdansk,poznan,trojmiasto,katowice,slask,lodz,bialystok,gdynia,lublin,rzeszow,bydgoszcz,gliwice,czestochowa,szczecin,sopot&page=",
  1:442
)

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

    write_lines(urlsList %>% unlist() %>% unique(),
      file = paste0("urlsList_", format(Sys.time(), "%x_%X"), ".csv")
    )
  }
}