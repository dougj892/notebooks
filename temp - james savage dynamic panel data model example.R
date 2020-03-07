
library(rstanarm); library(tidyverse)

# Simulate some fake data
delta <- 0.5
sigma_u <- 2
sigma_e <- 1
I <- 100
T <- 10

initial_values <- data_frame(individual = 1:I,
                             initial_y = rnorm(I),
                             u = rnorm(I, 0, sigma_u))


simulated_panel <- initial_values %>%
  group_by(individual) %>% 
  do({
    simulate <- function(x) {
      out <- data.frame(y = rep(NA, T),
                        time = rep(NA, T),
                        u = x$u) # this line is confusing. how is length(x$u) == T?
      for(t in 1:T) {
        out$time[t] <- t
        if(t == 1) {
          out$y[t] <- rnorm(1, delta * x$initial_y + x$u, sigma_e)
        } else {
          out$y[t] <- rnorm(1, delta * out$y[t-1] + x$u, sigma_e)
        }
      }
      return(out)
    }
    as.data.frame(simulate(.))
  }) %>% 
  group_by(individual) %>% 
  mutate(lagged_y = lag(y)) %>% 
  filter(!is.na(lagged_y))


cor(simulated_panel$lagged_y, simulated_panel$u)

test_fit <- stan_lmer(y ~ lagged_y + (1 | individual), data = simulated_panel, iter = 1000, cores = 4)

bayesplot::mcmc_dens(as.data.frame(test_fit), pars = "lagged_y") +
  geom_vline(aes(xintercept = delta)) +
  annotate("text", y = 15, x = delta + 0.05, label = "true coef") +
  xlim(0, max(as.data.frame(test_fit)$lagged_y))