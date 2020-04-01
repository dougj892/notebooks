library(tidyverse)
library(haven)
dlhs_path <- "C:/Users/dougj/Documents/Data/DLHS/DLHS3IIND"
dlhs <- read_spss(file.path(dlhs_path, "DLHS3IIND.sav"))
