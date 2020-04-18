# Create consolidated country dataset of findex, aspire, and aspire data


# Load libraries and set paths
library(tidyverse)
library(haven)
library(readxl)
library(writexl)
data_path <- "C:/Users/dougj/Dropbox/Covid Social Protection/Data"


############# PROCESS IFC FAS DATASET ################

ifc <- read_dta(file.path(data_path, "Raw", "IFC FAS data.dta"))

# Add "ifc" prefix to all column names and then change a few back
colnames(ifc) <- paste("ifc_", colnames(ifc), sep ="")
ifc <- ifc %>% rename(year = ifc_year, country = ifc_economy, ccode = ifc_iso3)

# The dataset has data for multiple years. Just get the most recent year.
ifc_latest <- ifc %>% filter(year == 2018)

# Create function to test whether there are any non-NA values in a vector.  Will use this to filter for
# variables that have at least one non-missing
all_na <- function(x) any(!is.na(x))

ifc_latest <- ifc_latest %>% select_if(all_na)

###### THE NEXT 10 OR SO LINES DETERMINES MOST RECENT YEAR OF NON-MISSING DATA
###### SEEMS LIKE IT IS 2018 FOR MOST VARIABLES SO OK TO JUST USE 2018

# convert all of the columns to numeric so I can pivot the data
# ifc[4:ncol(ifc)] <- sapply(ifc[4:ncol(ifc)], as.numeric)
# 
# # Look at whether I should not just take the latest year for this data
# latest_year <- ifc %>%
#   select(-country) %>%
#   pivot_longer(-c("ccode", "year"), names_to = "var", values_to = "value") %>%
#   filter(!is.na(value)) %>%
#   group_by(ccode, var) %>%
#   summarise(latest = max(year))



############# PROCESS FINDEX DATASET ################
findex <- read_excel(file.path(data_path, "Raw", "Global Findex Database.xlsx"))

# Add "fdx" prefix to all column names and then change a few back
colnames(findex) <- paste("fdx_", colnames(findex), sep ="")
findex <- findex %>% rename(year = fdx_...1, 
                             ccode = fdx_...2, 
                             country = fdx_...3, 
                             region = fdx_...4, 
                             income_level = fdx_...5)

# select on year 2017 (the most recent year), add "fdx" predix to var names, and then change some names back
findex_latest <- findex %>%  filter(year == 2017)

# drop any columns that are all na
findex_latest <- findex_latest %>% select_if(all_na)




###### MERGE JUST FINDEX AND IFC #########
merged <- ifc_latest %>% 
  full_join(findex_latest, by = "ccode")


# select only the most useful columns
# filter for useful variables in the FDX, FAS dataset
merged <- merged %>% 
  select(country = country.x, ccode,
         `fdx_Account (% age 15+)`,
         `fdx_Received wages: in cash only (% age 15+)`,
         `fdx_Has a national identity card (% age 15+)`,
         `fdx_Mobile money account (% age 15+)`,
         `fdx_Received wages in the past year (% age 15+)`,
         ifc_i_branches_A1_pop,
         ifc_i_branches_A2_pop,
         ifc_i_branches_A3B1a_pop,
         ifc_i_ATMs_pop,
         ifc_i_mob_agent_active_pop,
         ifc_i_nonbranch_A1_pop,
         region,
         income_level)

# read in the ilo data and merge with that as well
ilo <- read_csv(file.path(data_path, "Clean", "ilo_clean.csv"))
merged2 <- merged %>% left_join(ilo, by = "ccode")

# Save the merged dataset as an R
write_xlsx(merged2, path =file.path(data_path, "Clean", "fdx_fas_ilo_latest.xlsx")) 




