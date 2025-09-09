library(tidyverse)


### conditional statements

age = 70
if (age > 65) agecat = "Old" else agegat = "Young"
agecat


# age = NA_real_

if (age < 1) {
  work = "unemployable"
} else if (age > 67) {
  work = "can retire"
} else if (age >= 8 & age < 15) {
  work = "allowance"
} else if (age > 22) {
  work = "adulting"
} else {
  work = "Auntie Annes"
}

work

work = case_when(age < 1 ~ "unemployable",
                 age > 67 ~ "can retire",
                 age >= 8 & age < 15 ~ "allowance",
                 age > 22 ~ "adulting",
                 .default ~ "Auntie Annes")

work

#### summarizing data

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


### creating flags
data =
  tibble(id = paste("P000", seq(1:8), sep = ""),
         dx_date = as.Date(c("2024-01-10", "2024-03-05", "2024-02-01",
                             "2024-05-10", "2024-06-01", "2024-04-15",
                             "2023-12-10", "2024-07-07")),
         test_a = as.Date(c("2024-01-20", NA, "2024-01-25", "2024-05-25",
                             NA, "2024-04-20", "2023-12-05", NA)),
         test_b = as.Date(c("2024-02-15", "2024-03-20", "2024-02-10", NA,
                             NA, "2024-04-30", NA, "2024-07-10")),
         specimen = c("tissue", NA, "tissue", "blood", NA, "blood", "tissue", NA),
         clinic = c("North", "East", "North", "North", "East", "East", "North", "North"))
data

data =
  data %>%
  mutate(flag_test = !is.na(test_a) & !is.na(test_b) & test_a >= dx_date & test_b >= dx_date,
         flag_tissue = !is.na(specimen) & specimen == "tissue",
         flag_north = clinic == "North")


data =
  data %>%
  mutate(valid = flag_test | flag_tissue,
         valid2 = (test_a >= dx_date & !is.na(test_a)) &
           (test_b >= dx_date & !is.na(test_b)) |
           (!is.na(test_a) & specimen == "tissue"))

all.equal(data$valid, data$valid2)

### subset data

data_subset =
  data %>%
  filter(flag_north)


data_subset
data_subset =
  data %>%
  filter(flag_test | flag_tissue)

data_subset

## summarizing by groups

data = tibble(age = c(19, 22, 27, 31, 35, 38, 42, 24, 29, 33),
              sex = c("F", "M", "M", "M", "F", "F", "M", "F", "F", "M"))


summary(data$age)

data %>%
  group_by(sex) %>%
  summarize(across(age, .fns = list(min = min, mean = mean, max = max)))

data = data %>%
  mutate(income = c(100000, 27000, 38000, 3000, 299000, 120000, 56000, 78000, 200000, 96000))


data %>%
  filter(age > 18) %>%
  group_by(sex) %>%
  summarize(across(income, .fns = list(min = min, mean = mean, max = max)))

# order matters!
data %>%
  group_by(sex) %>%
  summarize(across(income, .fns = list(min = min, mean = mean, max = max))) %>%
  filter(age > 18)


### problem set

df = read_csv(here::here("data", "community_health_week2.csv"))

df %>%
  group_by(sex) %>%
  summarize(q25 = quantile(diastolic_bp, 0.25, na.rm = TRUE),
         q75 = quantile(diastolic_bp, 0.75, na.rm = TRUE))

df %>%
  group_by(site) %>%
  filter(!is.na(smoking_status)) %>%
  summarize(n = n(),
            n_smokers = sum(smoking_status == "Current"),
            prop_smokers = n_smokers/n)
