# Check out the ASPIRE dataset
# Since almost all of the data in this dataset is missing, I am not using it for now.

# Load libraries and set paths
library(tidyverse)
library(haven)
library(readxl)
data_path <- "C:/Users/dougj/Dropbox/Covid Social Protection/Data/Raw"

aspire <- read_xlsx(file.path(data_path, "Aspire data.xlsx"))
colnnames(aspire)[1:4] <- c("country", "ccode", "indicator", "ind_code")


# just count the number of non-null values for each year --> for some reason read_csv isn't reading this data correctly
aspire %>% summarize_all(.funs = function (x) sum(!is.na(x) & (x != FALSE))) %>% select(-country, )



# 
# 
# key_indicators <- c("per_sa_ct.cov_pop_tot","per_sa_allsa.cov_pop_tot","per_lm_alllm.cov_pop_tot",
#                     "per_sa_ik.cov_pop_tot","per_sa_sf.cov_pop_tot","per_allsp.cov_pop_tot",
#                     "per_sa_cc.adq_pop_tot")
# 
# 
# # There are tons of variables in the ASPIRE dataset.  Filter for variables related to coverage for the entire population
# aspire <- aspire %>% filter(`Indicator Code` %in% key_indicators) %>% select(-`2008-16`, -X25)
# 
# # Generate a dataframe showing the number of variables non-missing by country and year
# aspire_long <- aspire %>% pivot_longer(cols = `1998`:`2016`, names_to = "year", values_to = "value")
# num_vars_non_missing <- aspire_long %>% 
#   group_by(`Country Name`, year) %>% 
#   summarise(total_non_missing = length(key_indicators)-sum(is.na(value))) %>% 
#   filter(total_non_missing >= 1) %>% 
#   ungroup()
# 
# 
