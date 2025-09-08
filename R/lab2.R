library(tidyverse)

data = tibble(age = c(47, 81, 65, NA_real_))

data 

data$agecat = if_else(data$age > 65, "old", "young")

data


set.seed(123)
data = tibble(age = runif(n = 10, min = 0, max = 70)) %>% 
  bind_rows(tibble(age = c(12, 18, NA_real_)))



data %>% 
  mutate(work = ifelse(age < 1, "unemployable",
                   ifelse(age > 67, "can retire",
                          ifelse(age >= 8 & age < 15, "allowance",
                                 ifelse(age > 22, "adulting", "Auntie Annes")))))

data %>% 
  mutate(work = case_when(age < 1 ~ "unemployable",
                          age > 67 ~ "can retire",
                          age >= 8 & age < 15 ~ "allowance",
                          age > 22 ~ "adulting",
                          .default = "Auntie Annes"))

data = tibble(age = c(19, 22, 27, 31, 35, 38, 42, 24, 29, 33),
              parity = c(1, 0, 2, 3, 4, 5, 6, 1, 2, 3),
              live_birth = c(1, NA, 2, 2, 3, 4, 4, NA, 1, 3))
data

mean(data$age)
median(data$parity)
max(data$live_birth)
max(data$live_birth, na.rm = TRUE)

data = 
  data %>% mutate(high_risk = c(1, 0, 0, 0, 0, 1, 1, 0, 0, 0))

data


data %>% 
  group_by(high_risk) %>% 
  summarize(max_live_births = max(live_birth, na.rm = TRUE))

data %>% 
  mutate(high_risk = (age < 20 & parity >= 1) | (age > 35 & parity >= 5))

data %>% 
  mutate(ind = row_number()) %>% 
  mutate(age = if_else(ind %in% c(1, 4), NA_real_, age)) %>% 
  mutate(high_risk = (age < 20 & parity >= 1) | (age > 35 & parity >= 5))


