******************************************************
* lab 2 stata code for demo 
******************************************************

clear all
set more off

******************************************************
* 1. Conditional statements
******************************************************

set obs 1
gen age = 70

* if/else: age category
gen str agecat = cond(age > 65, "Old", "Young")
list age agecat

* multi-branch if/else
gen str work = cond(age < 1, "unemployable", cond(age > 67, "can retire", cond(inrange(age,8,14), "allowance", cond(age > 22, "adulting", "auntie annes"))))
list age work

clear all
set obs 1
gen age = .
gen str20 work = ""
replace work = "unemployable" if age < 1
replace work = "can retire"   if age > 67
replace work = "allowance"    if age >= 8 & age < 15
replace work = "adulting"     if age > 22 
* replace work = "Auntie Annes" if age == .

list age work 

******************************************************
* 2. Summarizing data
******************************************************

clear
input age parity live_birth
19 1 1
22 0 .
27 2 2
31 3 2
35 4 3
38 5 4
42 6 4
24 1 .
29 2 1
33 3 3
end



* summary statistics
summ age
summ parity, detail    // median shown in detail
summ live_birth
summ live_birth, meanonly
display "Max live_birth: " r(max)

list
* add a flag variable
gen high_risk = (age < 25 & live_birth != . & live_birth >= 1) | (age > 35 & live_birth >= 5)

list age parity live_birth high_risk

* group summary: max live_birth by high_risk
bysort high_risk: egen max_live_births = max(live_birth)
collapse (max) max_live_births = live_birth, by(high_risk)
list

******************************************************
* 3. Creating flags (dates & categories)
******************************************************

clear
input str5 id str10 dx_date str10 test_a str10 test_b str10 specimen str10 clinic
"P0001" "2024-01-10" "2024-01-20" "2024-02-15" "tissue" "North"
"P0002" "2024-03-05" ""           "2024-03-20" ""       "East"
"P0003" "2024-02-01" "2024-01-25" "2024-02-10" "tissue" "North"
"P0004" "2024-05-10" "2024-05-25" ""           "blood"  "North"
"P0005" "2024-06-01" ""           ""           ""       "East"
"P0006" "2024-04-15" "2024-04-20" "2024-04-30" "blood"  "East"
"P0007" "2023-12-10" "2023-12-05" ""           "tissue" "North"
"P0008" "2024-07-07" ""           "2024-07-10" ""       "North"
end

* convert string dates to Stata dates
gen dx_date_s   = date(dx_date,"YMD")
gen test_a_s    = date(test_a,"YMD")
gen test_b_s    = date(test_b,"YMD")
format dx_date_s test_a_s test_b_s %td

* create flags
gen flag_test   = !missing(test_a_s) & !missing(test_b_s) & test_a_s >= dx_date_s & test_b_s >= dx_date_s
gen flag_tissue = specimen == "tissue"
gen flag_north  = clinic == "North"

list 
* combined validity flags
gen valid  = flag_test | flag_tissue
gen valid2 = (test_a_s >= dx_date_s & !missing(test_a_s)) & ///
             (test_b_s >= dx_date_s & !missing(test_b_s)) | ///
             (!missing(test_a_s) & specimen == "tissue")

list valid valid2 
******************************************************
* 4. Subset data
******************************************************

* keep only flag_north
preserve
keep if !flag_north
list
restore

* keep flag_test or flag_tissue
preserve
keep if flag_test | flag_tissue
list
restore



******************************************************
* 5. Summarizing by groups
******************************************************

******************************************************
* 5. Summarizing by groups
******************************************************

clear
input age str1 sex
19 "F"
22 "M"
27 "M"
31 "M"
35 "F"
38 "F"
42 "M"
24 "F"
29 "F"
33 "M"
end

list

* summary
summ age

* group summary for age
collapse (min) min_age=age ///
         (mean) mean_age=age ///
         (max) max_age=age, by(sex)

list

* collapse 

* add income
gen income = .
replace income = 100000 in 1
replace income = 27000  in 2
replace income = 38000  in 3
replace income = 3000   in 4
replace income = 299000 in 5
replace income = 120000 in 6
replace income = 56000  in 7
replace income = 78000  in 8
replace income = 200000 in 9
replace income = 96000  in 10
list sex age income

* summarize by sex for age>18
keep if age > 18

bysort sex: egen min_income = min(income)
bysort sex: egen mean_income = mean(income)
bysort sex: egen max_income = max(income)
collapse (min) min_income=income ///
         (mean) mean_income=income ///
         (max) max_income=income, by(sex)
list

******************************************************
* End of script
******************************************************
