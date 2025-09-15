library(tidyverse)


### recoding variables

data = tibble(
  patient = 1:10,
  age = c(85, 50, 36, 65, 42, 31, 73, 46, 5, 10),
  education = c("HS", "BS", "Grad", "No HS", "No HS", "HS", "Grad", "BS", "Grad", "HS"),
  country = c(1, 2, 3, 4, 4, 1, 3, 4, 2, NA),
  surgery = c("Yes", NA, "No", "No", "No", NA, "Yes", "No", NA, "No")
)


data

data = data %>%
  mutate(
    age2 = case_when(
    age <= 18 ~ "Child",
    age > 18 & age < 65 ~ "Adult",
    age >= 65 ~ "Senior"))

data %>%
  select(age, age2)

data$age2 = ifelse(data$age <= 18, "Child",
                   ifelse(data$age > 18 & data$age < 65, "Adult",
                          ifelse(data$age >= 65, "Senior", NA)))

data %>%
  select(age, age2)

data = data %>%
  mutate(country2 =
           case_when(country == 1 ~ "USA",
                     country == 2 ~ "Canada",
                     country == 3 ~ "Japan",
                     .default = "China"))



data %>%
  select(country, country2)


data = data %>%
  mutate(country2 = ifelse(country == "USA", "USA",
                           ifelse(country == "2", "Canada",
                                  ifelse(country == "3", "Japan", "China"))))

data %>%
  select(country, country2)


## merging levels of a variable
data
data = data %>%
  mutate(education2 =
           case_when(education == "HS" | education == "No HS" ~ "No College",
                     education == "BS" | education == "Grad" ~ "College"))

data %>%
  select(education, education2)

# using base R
data$education2 = ifelse(data$education == "HS" | data$education == "No HS", "No College",
                  ifelse(data$education == "Grad" | data$education == "BS", "College", data$education))


# replace missing values
clean_data = data %>%
  mutate(surgery = case_when(
    is.na(surgery) & age < 18 ~ "No",
    is.na(surgery) ~ "Unknown",
    .default = surgery
  ))

clean_data

data

data %>%
  mutate(surgery = case_when(
    is.na(surgery) & age < 18 ~ "No",
    is.na(surgery) ~ "Unknown"
  ))


## replace missing values
data = data %>%
  mutate(surgery2 = case_when(
    is.na(surgery) & age < 18 ~ "No",
    is.na(surgery) ~ "Unknown",
    .default = surgery
  ))

data %>% select(age, surgery, surgery2)

## common pitfalls

age = 10
# how should I write the above?
age2 = if (age < 65) {
  "Adult"
} else if(age < 18) {
  "Child"
} else if(age >= 65) {
  "Senior"
}

age2
## order matters!

age2 = if (age < 18) {
  "Child"
} else if (age < 65) {
  "Adult"
} else if (age >= 65) {
  "Senior"
}

age2

sex = "Male"

if(sex = "Male") sex2 = M

if(sex == Male) sex2 = M

if(sex == "Male") sex2 = M

race = "Latino"

if (race == "White") {
  race2 = "W"
} else if (race == "Asian"){
  race2 = "A"
}

race2

data = tibble(race = c("White", "Asian", "Latino"))

data %>%
  mutate(race2 =
           case_when(race == "White" ~ "W",
                     race == "Asian" ~ "A"))

## creating a table one

data = tibble(patient = 1:10,
             age = c(85, 50, 36, 65, 42, 31, 73, 46, 5, 10),
             education = c("HS", "BS", "Grad", "No HS", "No HS", "HS", "Grad", "BS", "Grad", "HS"),
             education2 = c("No College", "College", "College", "No College", "No College", "No College", "College", "College", "College", "No College"),
             country = c(1, 2, 3, 4, 4, 1, 3, 4, 2, NA),
             country2 = c("USA", "Canada", "Japan", "China", "China", "USA", "Japan", "China", "Canada", NA),
             surgery = c("Yes", "Unknown", "No", "No", "No", "Unknown", "Yes", "No", "Unknown", "No"))

# install.packages("tableone")
library(tableone)

CreateTableOne(data = data,
               vars = c("age", "education2", "country2", "surgery"))

CreateTableOne(data = data,
               vars = c("age",  "country2", "surgery"),
               strata = "education2",
               test = FALSE,
               addOverall = TRUE)

# install.packages("gtsummary")
# install.packages("gt")
library(gtsummary)
library(gt)

data %>%
  select(-patient) %>%
  tbl_summary(
    by = NULL, # no stratification
    missing = "ifany"
  )

data %>%
  select(age, education2, country2, surgery) %>%
  tbl_summary(
    by = education2,
    missing = "ifany"
  ) %>%
  add_overall() %>%   # like addOverall=TRUE
  add_n() %>%         # show n in header
  modify_header(all_stat_cols() ~ "**{level}**") %>%
  bold_labels()


data %>%
  select(age, education2, country2, surgery) %>%
  tbl_summary(by = education2, missing = "ifany") %>%
  add_overall() %>%
  as_gt() %>%
  tab_header(title = "Patient Characteristics by Education Level") %>%
  tab_source_note(source_note = "Demo dataset")

## save it!

table = data %>%
  select(age, education2, country2, surgery) %>%
  tbl_summary(by = education2, missing = "ifany") %>%
  add_overall() %>%
  as_gt() %>%
  tab_header(title = "Patient Characteristics by Education Level") %>%
  tab_source_note(source_note = "Demo dataset")


gtsave(table, "table1.png")

gtsave(table, "table1.docx")


