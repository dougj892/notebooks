# temp -- explore the ASER microdata


library(tidyverse)
library(haven)

path <- "C:/Users/dougj/Documents/Data/Education/ASER microdata"

aserm <- read_dta(file.path(path, "ASER2007.dta"))