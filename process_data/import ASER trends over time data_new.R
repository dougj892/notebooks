# Import and clean ASER district data

# import packages
library(tidyverse)

raw <- "C:/Users/dougj/Documents/Data/Education/ASER trends over time/tabula output"

files <- list.files(raw)

if (exists("full")) {
  rm(full)
}

# Loop through each of the files outputted by tabula
for (file in files) {
  print(file)
  df <- read_csv(file.path(raw, file), col_names = FALSE)
  # Convert all columns to numeric
  df <- df %>% mutate_all(funs(as.numeric))
  # Rename X1 year and create a "table" variable. The table variable indicates the ASER report table number
  df <- df %>% rename(year = X1) %>% mutate(table = 1)
  # Identify where a new table starts by looking at rows where the year number is not greater than year in previous row
  iterator <- 1
  for (i in 2:nrow(df)) {
    if (df$year[i] < df$year[i-1]) {
      iterator = iterator + 1
    }
    df$table[i] <- iterator
  }
  # Reshape the dataset to wide. Note that many of the 
  df <- df %>% pivot_wider(names_from = table, values_from = c("X2","X3","X4","X5","X6","X7"), names_prefix = "tab")
  # Create a variable for state name (from the file name).
  df <- df %>% mutate(State_old = file)
  if (!exists("full")) {
    full <- df
    print("wrote over full")
  } else {
    full <- full %>% bind_rows(df)
    print("appended full")
  }
}

# Define a function to check whether all values are NA
not_all_na <- function(x) any(!is.na(x))

# Drop any columns for which all of the values are NA
full <- full %>% select_if(not_all_na)

# clean up the state variable
full <- full %>% separate(State_old, into = c("scrap","temp"), sep = "-") %>% separate(temp, into = c("State","scrap2"), sep = "\\.")
# drop intermediate columns
full <- full %>% select(-scrap, -scrap2)

# Do a batch rename. See the excel doc "tabula-andhrapradesh - with notes" for more info
full <- full %>%
  rename(num_dists=X2_tab1,
         num_villages=X3_tab1,
         num_hhs=X4_tab1,
         not_enrolled=X7_tab2,
         pvt_boys=X3_tab3,
         pvt_girls=X5_tab3,
         pvt=X7_tab3,
         std3_read_std1_all=X3_tab4,
         std3_read_std1_govt=X3_tab5,
         std3_read_std1_pvt=X5_tab5,
         std5_read_std2_all=X3_tab6,
         std5_read_std2_govt=X3_tab7,
         std5_read_std2_pvt=X5_tab7,
         std3_subtract_all=X3_tab8,
         std3_subtract_govt=X3_tab9,
         std3_subtract_pvt=X5_tab9,
         std5_divis_all=X3_tab10,
         std5_divis_govt=X3_tab11,
         std5_divis_pvt=X5_tab11)

# Drop all unnamed variables
full <- full %>% select(-starts_with("X"))

# Divide all variables by 100 excep state, num*, and year
divide.by.100 <- function(x, na.rm=FALSE) (x/100)
cols <- setdiff(names(full), c("num_dists", "num_hhs", "num_villages", "year", "State"))
full <- full %>% mutate_at(cols, divide.by.100)

write_csv(full, "C:/Users/dougj/Documents/Data/Education/ASER trends over time/aser_trends.csv")




