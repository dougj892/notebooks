# import and merge ILOStat data


# Load libraries and set paths
library(tidyverse)
library(haven)
library(readxl)
data_path <- "C:/Users/dougj/Dropbox/Covid Social Protection/Data"

ilo <- read_csv(file.path(data_path, "Raw", "ilostat-2020-04-17.csv"))


# just take the most interesting indicators for all population
ilo_slim <- ilo %>% filter(str_detect(sex.label, "Total")) %>% 
  mutate(ccode = str_sub(source.label, 1,3)) %>% 
  select(-indicator.label, -source.label, -sex.label) %>% 
  rename(country = ref_area.label, indicator = classif1.label, value = obs_value, year = time) %>% 
  filter(str_detect(indicator, "Poor persons") | str_detect(indicator, "Population covered") | str_detect(indicator, "Vulnerable"))

ilo_slim <- ilo_slim %>% mutate(ind = case_when(
  str_detect(indicator, "Poor persons") ~ "sp_cover_poor",
  str_detect(indicator, "Population covered") ~ "sp_cover_all",
  str_detect(indicator, "Vulnerable") ~ "sa_cover_vulnerable")) %>% 
  select(-indicator) %>% 
  mutate(value = value/100)

# get the most recent year for each of the indicators
ilo_latest <- ilo_slim %>% group_by(ccode, ind) %>%  top_n(n=1, -year) %>% ungroup()

# check that no countries have more than 3 rows
ilo_latest %>% count(ccode) %>% arrange(desc(n)) %>% count(n)

# check if the most recent year varies by country --> only mexico has more than one year.
ilo_latest %>% count(country, year) %>% count(country) %>% arrange(desc(n))

# assume that the year is 
ilo_wide <- ilo_latest %>% group_by(country) %>% mutate(ilo_year = max(year)) %>% 
  ungroup() %>% pivot_wider(names_from = ind, values_from = value)

write_csv(ilo_wide, file.path(data_path, "Clean", "ilo_clean.csv"))

