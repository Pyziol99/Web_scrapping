# webScrapping
webScrapping project on noFluffJobs.com for university studies.

In order to be able to obtain the data needed for the analysis, a number of steps had to be carried out, which were divided into attachments.
### "Functions.R"
 The _GET_urls_ function creates a directory of links to job listings based on the search page on the portal, in order to obtain detailed data for analysis. The links are obtained by using the appropriate-original _CSS_ elements. Error handling within the _tryCatch_ function has been included in the code to avoid premature termination of the data download due to an error.

 The _GET_Content_ function downloads, using the _GET_ method, the necessary data based on the link directory created using the author's _GET_urls_ function. The function works analogously to the GET_urls function, instead of links it pulls specific data.

 The _SalaryContract_ function creates a new column based on the selected column from the data frame with separated earnings. Giving it a name depending on the type of contract it is Business to Business, Employment Contract, Contract to Order, and Work Contract. In each cell, it puts the salary fork, information as to the pay period and currency.

 The function _ConversionToPLN_-already processed columns by wage type separates by maximum and minimum forks in separate columns, and converts based on current exchange rates and equalizes weekly and daily rates to monthly rates. The function takes the current rate data from the _Yahoo Finance_ service using the _getQuote_ function from the _quantmod_ library. This procedure significantly slows down the iteration of the for loop, no longer recommended for use in the R environment. In order to avoid each time communication with the page when calling the function, the fixed exchange rates to PLN as of 17.06.2022 were placed interchangeably.

 Function _Cleaning_requirements_ which creates splits the requirements column into logical columns using the map funckja for a given skill, depending on whether it is required in a given bid. The funckja selects requirements that appear in at least 10% of the bids.


### "GET_data.R"
The first action after loading the data was to create a database of all the pages of the catalog for searching for offers. In order to get the maximum number of listings, all possible locations were selected, and then 442 links were created to the following search pages on the portal.

Then, from the generated links, the downloading of links in a for loop to specific job listings began.

### "Data_initial_cleaning.R".
A data frame of 8808 rows and 6 lines was obtained.
In the initial cleaning phase, it was necessary to:
 1. rename urlsCatalog to url
 2. remove free internship offers
 3. remove duplicate listings. Certain listings were duplicated for several locations.
 4. Leave only the company name in the _title_company_ column.
 5. Replace the _category_ column as _position_.
 6. select only the minimum experience level and overwrite the _level_ column.
 7. remove Polish characters from the _salary_ column.

### "Data_cleaning_salary.R".
 In the next appendix which organizes the initial Salary column first, the earnings are divided by the "|" character with the _stri_split_ function and writes to the data frame. This produces 9 columns of earnings of which only the first column does not contain empty values. Then, for the first 3 earnings columns, it uses the previously created functions _SalaryContract_ and then _ConversionToPLN_ in turn. Finally, it removes the columns that are no longer needed. Thus, it returns a data frame after the initial cleaning with the salary column broken down into minimum and maximum earnings for a given contract type and unified as to currency and pay period. The result writes to a file.

### "Final_dataset.R"
In the last file, a final data frame is created, which merges using the _cbind_ function the frame created in the _"Data_cleaning_salary.R"_ file and using the _Cleaning_requirements_ function. A data frame with 4169 rows and 115 columns was obtained. It will be subjected to proper analysis. The data was saved in the file _Final_dataset.csv_.

### "Raport.rmd"
An rmd file that creates a dynamic report describing the data acquisition procedure and brief descriptive statistics of the data.

