## Lab demo code available here: https://github.com/lilykoff/jhsph_620s

library(tidyverse)

## Harmonize data
data = tibble(
  patient = 1:8,
  country = c(1, 2, 1, 2, 2, 1, 2, 1),
  drug = c("Acetaminophen", "Placebo", "Acetaminophen", "Acetominophen", "Placebo", "Placido", "Acetaminophen", "Placebo"),
  enroll_date = c("05/01/2025", "07/01/2025", "05/15/2025", "14/02/2025", "23/03/2025", "06/03/2025", "30/04/2025", "07/20/2025")
)

# Create new variables
data <- data %>%
  mutate(tx_group = (drug == "Acetaminophen"),
         .after = drug)

data <- data %>%
  mutate(enroll_month = month(as.Date(enroll_date, format = "%m/%d/%Y"), label = TRUE))  # format specified

data <- data %>%
  mutate(enroll_month2 = month(as.Date(enroll_date), label = TRUE))  # format unspecified

data <- data %>%
  select(-enroll_month2)

## Spotting inconsistencies
# Check unique values
unique(data$drug)

# Subset to errors
data %>%
  filter(is.na(enroll_month))

## Fix errors
# Manual fix
data <- data %>%
  mutate(enroll_date_mdy = case_when(enroll_date == "07/01/2025" ~ "01/07/2025",
                                     enroll_date == "14/02/2025" ~ "02/14/2025",
                                     enroll_date == "23/03/2025" ~ "03/23/2025",
                                     enroll_date == "30/04/2025" ~ "04/30/2025",
                                     TRUE ~ enroll_date)
  )

data <- data %>%
  mutate(enroll_month_manual = month(as.Date(enroll_date_mdy, format = "%m/%d/%Y"), label = TRUE))

data %>%
  select(enroll_date, enroll_month, enroll_date_mdy, enroll_month_manual)

# By country code
data <- data %>%
  mutate(enroll_date_ymd = if_else(country == 2, dmy(enroll_date), mdy(enroll_date)))  # warnings are okay

data <- data %>%
  mutate(clean_enroll_month = month(enroll_date_ymd, label = TRUE))

data %>%
  select(enroll_date, enroll_date_ymd, clean_enroll_month)

unique(data$clean_enroll_month)
data %>% filter(is.na(clean_enroll_month))
data %>%
  filter(enroll_month != clean_enroll_month | is.na(enroll_month)) %>%
  select(patient, country, enroll_date, enroll_month, enroll_date_ymd, clean_enroll_month)


## Insurance example
data = tibble(
  patient = c(1001:1005, 1007:1012, 1015),
  source = c("claims", "claims", "claims", "EHR", "EHR", "survey", "survey",
             "survey","claims", "claims", "EHR", "survey"),
  provider = c("UPenn", "JHU", "UPenn", "UPenn", "MassGen", "JHU", "JHU",
               "MassGen", "MassGen", "UPenn", "MassGen", "JHU"),
  insurance = c("Medicaid", "Privete Insurance", "Uninsured", "Medicaid",
                "Private", "Medicaid Program", "Private Insurance",
                "No Insurance", "medicaid", "Private Insurance", "No Insurance",
                "Medicaid")
  )

data
unique(data$insurance)

## Sidebar: Regex example
df <- tibble(
  patient = 1:6,
  var1 = c("cat", "dog", "bobcat", "scathing", "Cats are great!", "Cats are a catastrophe!")
)

df <- df %>%
  mutate(dected = str_detect(var1, "cat"))

df <- df %>%
  mutate(dected_lower = str_detect(tolower(var1), "cat"))

## end sidebar

# Convert string to lowercase
data <- data %>%
  mutate(insurance_lower = tolower(insurance))

# Partial solution
data <- data %>%
  mutate(clean_insurance = case_when(str_detect(insurance_lower, "private") ~ "Private",
                                     str_detect(insurance_lower, "medicaid") ~ "Medicaid",
                                     TRUE ~ insurance)
  )

data
unique(data$clean_insurance)

# Better solution
data <- data %>%
  mutate(clean_insurance = case_when(str_detect(insurance_lower, "private") | insurance_lower == "privete insurance" ~ "Private",
                                     str_detect(insurance_lower, "medicaid") ~ "Medicaid",
                                     insurance_lower == "no insurance" ~ "Uninsured",
                                     TRUE ~ insurance)
  )

data
unique(data$clean_insurance)
unique(data[,c("insurance", "clean_insurance")])
