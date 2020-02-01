# Import and clean ASER district data

# import packages
library(tidyverse)

raw <- "C:/Users/dougj/Documents/Data/Education/ASER trends over time/tabula output"

files <- list.files(raw)

if (exists("full")) {
  rm(full)
}

for (file in files) {
  print(file)
  df <- read_csv(file.path(raw, file), col_names = FALSE)
  df <- df %>% mutate_all(funs(as.numeric))
  df <- df %>% rename(year = X1) %>% mutate(table = 1)
  iterator <- 1
  for (i in 2:nrow(df)) {
    if (df$year[i] < df$year[i-1]) {
      iterator = iterator + 1
    }
    df$table[i] <- iterator
  }
  df <- df %>% pivot_wider(names_from = table, values_from = c("X2","X3","X4","X5","X6","X7"), names_prefix = "tab")
  df <- df %>% mutate(State_old = file)
  if (!exists("full")) {
    full <- df
    print("wrote over full")
  } else {
    full <- full %>% bind_rows(df)
    print("appended full")
  }
}


not_all_na <- function(x) any(!is.na(x))

# run this after combining all of the datasets
full <- full %>% select_if(not_all_na)

# clean up the state variable
full <- full %>% separate(State_old, into = c("scrap","temp"), sep = "-") %>% separate(temp, into = c("State","scrap2"), sep = "\\.")
# drop intermediate columns
full <- full %>% select(-scrap, -scrap2)


full <- full %>%
  rename(std3_reading = X3_tab4, std3_math = X3_tab8)
write_csv(full, "C:/Users/dougj/Documents/Data/Education/ASER trends over time/aser_trends.csv")



