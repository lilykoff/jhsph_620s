* R to Stata Translation
* Original R script translated to Stata syntax

clear all

*** Creating the initial dataset ***

input patient age str10 education country str10 surgery
1 85 "HS" 1 "Yes"
2 50 "BS" 2 ""
3 36 "Grad" 3 "No"
4 65 "No HS" 4 "No"
5 42 "No HS" 4 "No"
6 31 "HS" 1 ""
7 73 "Grad" 3 "Yes"
8 46 "BS" 4 "No"
9 5 "Grad" 2 ""
10 10 "HS" . "No"
end

* For string variables, missing is represented by empty string ""
* The NA values in R become empty strings in Stata for string variables
* No need to convert - empty strings are already the missing representation

list

*** Variable Recoding ***

* Age categories using replace 
generate str10 age2 = ""
replace age2 = "Child" if age <= 18
replace age2 = "Adult" if age > 18 & age < 65
replace age2 = "Senior" if age >= 65

list patient age age2


* Country recoding
generate str10 country2 = ""
replace country2 = "USA" if country == 1
replace country2 = "Canada" if country == 2
replace country2 = "Japan" if country == 3
replace country2 = "China" if country == 4 | (country != 1 & country != 2 & country != 3 & !missing(country))

list patient country country2

* Country recoding
generate str10 country3 = "China"
replace country3 = "USA" if country == 1
replace country3 = "Canada" if country == 2
replace country3 = "Japan" if country == 3

list patient country country2 country3 

* Education level merging
generate str15 education2 = ""
replace education2 = "No College" if education == "HS" | education == "No HS"
replace education2 = "College" if education == "BS" | education == "Grad"

list patient education education2

* Replace missing values in surgery based on conditions
generate str10 surgery2 = surgery
replace surgery2 = "No" if surgery == "" & age < 18
replace surgery2 = "Unknown" if surgery == "" & age >= 18

list patient age surgery surgery2

*** Common pitfalls examples ***

* Order matters example
scalar age_test = 10

* Wrong order (like in R example)
local age2_wrong = ""
if age_test < 65 {
    local age2_wrong = "Adult"
}
else if age_test < 18 {
    local age2_wrong = "Child"
}
else if age_test >= 65 {
    local age2_wrong = "Senior"
}
display "Wrong order result: `age2_wrong'"

* Correct order
local age2_correct = ""
if age_test < 18 {
    local age2_correct = "Child"
}
else if age_test < 65 {
    local age2_correct = "Adult"
}
else if age_test >= 65 {
    local age2_correct = "Senior"
}
display "Correct order result: `age2_correct'"

*** Creating summary tables (Table One equivalent) ***

* Clean up the dataset for final analysis
drop country2 surgery2
generate str10 country2 = ""
replace country2 = "USA" if country == 1
replace country2 = "Canada" if country == 2
replace country2 = "Japan" if country == 3
replace country2 = "China" if country == 4

generate str10 surgery_clean = surgery
replace surgery_clean = "Unknown" if surgery == ""

* Basic descriptive statistics (equivalent to CreateTableOne)
tabstat age, statistics(mean sd min max) columns(statistics)
tab education2
tab country2
tab surgery_clean

* Stratified analysis by education level
display "=== Stratified by Education Level ==="
bysort education2: tabstat age, statistics(mean sd) columns(statistics)

display "Country by Education:"
tab country2 education2, col

display "Surgery by Education:"
tab surgery_clean education2, col

* For more sophisticated table one functionality, you would need:
* ssc install table1_mc
* or
* ssc install tableone

* Example with table1_mc (if installed):
table1_mc, by(education2) vars(age contn \ country2 cate \ surgery_clean cate)

*** Export tables ***

* Export to Excel
* putexcel set "table1.xlsx", replace
* putexcel A1 = "Patient Characteristics"
* (add more putexcel commands to build table)

* Or use estout package for formatted output:
* ssc install estout
* estpost tabstat age, by(education2) statistics(mean sd)
* esttab using "table1.rtf", cells("mean sd") replace

* Alternative: Use asdoc package for formatted output
* ssc install asdoc
* asdoc tabstat age, by(education2) statistics(mean sd) save(table1.doc) replace

