# Import and clean Ugo's data

# import libraries
library(tidyverse)
library(readxl)
library(fuzzyjoin)


path <- "C:/Users/dougj/Dropbox/Covid Social Protection/Data"
file <- "Ugo April 10.xlsx"
covsp <- read_excel(file.path(path, "Raw", file))

# Drop the description variable for now since it is too difficult to parse
covsp <- covsp %>% select(-description)

# drop rows where all vars are NA
covsp <- covsp %>% filter_all(any_vars(!is.na(.)))


# Go row by row and replace any rows with the value from the previous row if the row is blank
for (i in 2:nrow(covsp)) {
  for (var in colnames(covsp)) {
    if (is.na(covsp[[var]][i])) {
      covsp[[var]][i] <- covsp[[var]][i-1]
    }
  }
}


# Load dataframe with 3 digit ISO country code and country names
countries <- read_csv(file.path(path, "Raw", "countries_for_ugo_data.csv"))

# trim the country variable to make it easier to merge
covsp <- covsp %>% mutate(country = str_trim(country))

# check out the countries that we can't merge (they are all small rich countries)
covsp %>% anti_join(countries) %>% count(country)

# merge the dataframes to get the ISO country codes
covsp <- covsp %>% inner_join(countries)




# Get the first three words from the type fields
covsp <- covsp %>% 
  mutate(category = str_to_lower(str_trim(category)), 
         type = str_to_lower(str_trim(type)),
         short_type = str_extract(paste(type, " "), "^(\\w+[\\s+-/]){1,3}"),
         change = str_extract(type, "(new|adaptation)")) %>% 
  mutate(short_type = str_trim(short_type))

type_clean <- read_csv(file.path(path, "Raw", "cleaned_types_ugo.csv"))

covsp <- covsp %>% left_join(type_clean) %>% select(-n)

covsp <- covsp %>% mutate(category = recode(category, 
                                            "labor markers" = "labor markets",
                                            "labor market" = "labor markets"))

covsp <- covsp %>% mutate(simp_type =case_when(
  str_detect(short_type, "cash") ~ "cash",
  str_detect(short_type, "childcare") ~ "childcare",
  str_detect(short_type, "health") ~ "health insurance",
  str_detect(short_type, "pension") ~ "pension",
  str_detect(short_type, "labor") ~ "labor regulation",
  str_detect(short_type, "unemployment") ~ "unemployment benefit",
  str_detect(short_type, "utilit") ~ "utilities",
  str_detect(short_type, "wage") ~ "wage subsidy",
  str_detect(short_type, "kind") ~ "in-kind support",
  str_detect(short_type, "social security") ~ "social security contribution",
  str_detect(short_type, "electricity") ~ "utilities",
  str_detect(short_type, "universal") ~ "cash",
  str_detect(short_type, "expansion of") ~ "cash",
  str_detect(short_type, "leave") ~ "paid leave",
  TRUE ~ short_type))

covsp <- covsp %>% select(-short_type, -type_new)


write_csv(covsp, path = file.path(path, "Clean", "ugo_april_10_clean.csv"))
