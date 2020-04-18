
library(tidyverse)

outcomes <- c("mpg", "disp")
sub_data <- c("mtcars$cyl >=6", "mtcars$wt > 2")
models <- expand.grid(y = outcomes, condition = sub_data) %>% 
  mutate_all(as.character)


fit <- function(y, condition) {
  # Create the formula to use in all models
  rx <- paste(y, "~ hp + am")
  log_vec <- eval(parse(text = condition))
  lm(rx, data = mtcars[log_vec,])
}


t <- pmap(models, fit) 