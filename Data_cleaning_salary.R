library(tidyverse)
library(stringi)
library(rvest)
library(dplyr)
library(httr)
library(quantmod)


df <- read.csv2("catalog_noFluffJobs_initially_cleaned.csv")

# rozdzielenie kolumny salary na ilości płac
salary <- df$salary %>%
  stri_split(fixed = "|", simplify = T) %>%
  as.data.frame()


salary1 <- SalaryContract(1, salary)
salary2 <- SalaryContract(2, salary)
salary3 <- SalaryContract(3, salary)
# dodanie do całościowej ramki danych kolumn w zależności od numeru salary i rodzaju umowy
# wymieniony zostały każdy numer kolumny aby można było rozróżnić numer salary
df <- df %>% add_column(salary1B2B = salary1$B2B, salary1UoP = salary1$UoP, salary1UZ = salary1$UZ, salary1UoD = salary1$UoD, .before = "url")
df <- df %>% add_column(salary2B2B = salary2$B2B, salary2UoP = salary2$UoP, salary2UZ = salary2$UZ, salary2UoD = salary2$UoD, .before = "url")
df <- df %>% add_column(salary3B2B = salary3$B2B, salary3UoP = salary3$UoP, salary3UZ = salary3$UZ, salary3UoD = salary3$UoD, .before = "url")
df$salary <- NULL

# uzyskanie właściwych pól salary, przewalutowanych oraz z podziałem na Min i Max dla każdego typu umowy

# salary1
salary1B2B <- GetRightSalary(df$salary1B2B)
salary1UoP <- GetRightSalary(df$salary1UoP)
salary1UZ <- GetRightSalary(df$salary1UZ)
salary1UoD <- GetRightSalary(df$salary1UoD)
df <- df %>% add_column(salary1B2BMin = salary1B2B$salaryRangeMinConv, salary1B2BMax = salary1B2B$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary1UoPMin = salary1UoP$salaryRangeMinConv, salary1UoPMax = salary1UoP$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary1UZMin = salary1UZ$salaryRangeMinConv, salary1UZMax = salary1UZ$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary1UoDMin = salary1UoD$salaryRangeMinConv, salary1UoDMax = salary1UoD$salaryRangeMaxConv, .before = "url")
# salary2
salary2B2B <- GetRightSalary(df$salary2B2B)
salary2UoP <- GetRightSalary(df$salary2UoP)
salary2UZ <- GetRightSalary(df$salary2UZ)
salary2UoD <- GetRightSalary(df$salary2UoD)
df <- df %>% add_column(salary2B2BMin = salary2B2B$salaryRangeMinConv, salary2B2BMax = salary2B2B$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary2UoPMin = salary2UoP$salaryRangeMinConv, salary2UoPMax = salary2UoP$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary2UZMin = salary2UZ$salaryRangeMinConv, salary2UZMax = salary2UZ$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary2UoDMin = salary2UoD$salaryRangeMinConv, salary2UoDMax = salary2UoD$salaryRangeMaxConv, .before = "url")
# salary3
salary3B2B <- GetRightSalary(df$salary3B2B)
salary3UoP <- GetRightSalary(df$salary3UoP)
salary3UZ <- GetRightSalary(df$salary3UZ)
salary3UoD <- GetRightSalary(df$salary3UoD)
df <- df %>% add_column(salary3B2BMin = salary3B2B$salaryRangeMinConv, salary3B2BMax = salary3B2B$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary3UoPMin = salary3UoP$salaryRangeMinConv, salary3UoPMax = salary3UoP$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary3UZMin = salary3UZ$salaryRangeMinConv, salary3UZMax = salary3UZ$salaryRangeMaxConv, .before = "url")
df <- df %>% add_column(salary3UoDMin = salary3UoD$salaryRangeMinConv, salary3UoDMax = salary3UoD$salaryRangeMaxConv, .before = "url")
#############################
df[5:16] <- NULL

####################################################################################################
write.csv2(df, "Cleaned_salary.csv", row.names = F)
