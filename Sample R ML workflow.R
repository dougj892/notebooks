# Sample machine learning work flow from the Data Camp course ML in R with tidyverse

library(tidyverse)
library(rsample)
library(Metrics)

# split the data into training and test data
set.seed(42)
data_split <- initial_split(iris, prop = .75)
training_data <- training(data_split)
test_data <- testing(data_split)

# Create cross fold object
cv_split <- vfold_cv(training_data, v = 5)
# Create separate columns with training and testing data by calling training and testing 
# on each of the splits
cv_data <- cv_split %>% 
  mutate(
    # Extract the train dataframe for each split
    train = map(splits, ~training(.x)),
    # Extract the validate dataframe for each split
    validate = map(splits, ~testing(.x))
  )


## TO TEST VARIOUS VALUES FOR HYPERPARAMETERS:
# USE CROSSING TO GENERATE DIFFERENT COMBOS OF FOLD + HYPERPARAMETER VALUE

# Fot a multinomial logit for each fold
library(nnet)
cv_models_lr <- cv_data %>% 
  mutate(model = map(train, ~multinom(formula = Species ~. , data = .x)))

# get the predicted values for each fold
cv_prep_lr <- cv_models_lr %>% 
  mutate(
    validate_actual = map(validate, ~.x$Species) ,
    validate_predicted = map2(.x = model, .y = validate, ~predict(.x, .y))
  )


# Calculate validation accuracy for each cross validation fold
cv_perf_recall <- cv_prep_lr %>%
  mutate(validate_accuracy = map2_dbl(validate_actual, validate_predicted,
                                    ~accuracy(actual = .x, predicted = .y)))

cv_perf_recall$validate_accuracy
mean(cv_perf_recall$validate_accuracy)

# ADD CODE: FIT THE BEST MODEL ON THE TRAINING DATA AND THEN USE THAT MODEL TO ASSESS ACCURACY ON TEST DATA

