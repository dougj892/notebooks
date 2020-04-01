# Calculate the odds that ICMR surveillance testing will turn up positives if there are positives

# Note that I assume that covid cases and regular pneumonia cases are equally likely to turn up at 
# ICMR lab hospital for treatment.

num_covid <- 100
prop_asymp <- .7

# According to one article, there are about 90 deaths due to adult pneumonia in India each year per 1 lakh
# 1 billion / 1 lakh = 10,000
# I assume a fatality rate of 10%
baseline_pne <- 5*90*10000/52

sample_size <- 500

prob_positive = 1-(1-num_covid*prop_asymp/baseline_pne)^sample_size
