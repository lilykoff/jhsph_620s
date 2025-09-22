clear
input patient country str20 drug str10 enroll_date
1 1 "Acetaminophen" "05/01/2025"
2 2 "Placebo"       "07/01/2025"
3 1 "Acetaminophen" "05/15/2025"
4 2 "Acetominophen" "14/02/2025"
5 2 "Placebo"       "23/03/2025"
6 1 "Placido"       "06/03/2025"
7 2 "Acetaminophen" "30/04/2025"
8 1 "Placebo"       "07/20/2025"
end

* 1. Treatment group: 1 if Acetaminophen, 0 otherwise
generate tx_group = (drug=="Acetaminophen")

* 2. Convert enroll_date into a Stata date
* First attempt with U.S. month/day/year
gen enroll_date_num = date(enroll_date, "MDY", 2025)
format enroll_date_num %td

* Extract month
gen enroll_month = month(enroll_date_num)
label define monthlbl 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values enroll_month monthlbl

* 3. Spot inconsistent dates
list patient enroll_date enroll_date_num if missing(enroll_date_num)

* 4. Manual fix: recode European-format dates
gen str10 enroll_date_mdy = enroll_date
replace enroll_date_mdy = "01/07/2025" if enroll_date=="07/01/2025"
replace enroll_date_mdy = "02/14/2025" if enroll_date=="14/02/2025"
replace enroll_date_mdy = "03/23/2025" if enroll_date=="23/03/2025"
replace enroll_date_mdy = "04/30/2025" if enroll_date=="30/04/2025"

* Parse again
gen enroll_date_num2 = date(enroll_date_mdy, "MDY", 2025)
format enroll_date_num2 %td
gen enroll_month_manual = month(enroll_date_num2)
label values enroll_month_manual monthlbl

* 5. By country: different parsing rules
gen enroll_date_ymd = .
replace enroll_date_ymd = date(enroll_date,"DMY",2025) if country==2
replace enroll_date_ymd = date(enroll_date,"MDY",2025) if country==1
format enroll_date_ymd %td

gen clean_enroll_month = month(enroll_date_ymd)
label values clean_enroll_month monthlbl

* Inspect mismatches
list patient country enroll_date enroll_month enroll_date_ymd clean_enroll_month if (enroll_month != clean_enroll_month | missing(enroll_month))



* Regex example
clear
input patient str40 var1
1 "cat"
2 "dog"
3 "bobcat"
4 "scathing"
5 "Cats are great!"
6 "Cats are a catastrophe!"
end

* Detect "cat" literally
gen detected = regexm(var1,"cat")

* Case-insensitive (force lowercase)
gen detected_lower = regexm(lower(var1),"cat")

list


* Insurance cleaning
clear
input patient str10 source str10 provider str20 insurance
1001 "claims" "UPenn"   "Medicaid"
1002 "claims" "JHU"     "Privete Insurance"
1003 "claims" "UPenn"   "Uninsured"
1004 "EHR"    "UPenn"   "Medicaid"
1005 "EHR"    "MassGen" "Private"
1007 "survey" "JHU"     "Medicaid Program"
1008 "survey" "JHU"     "Private Insurance"
1009 "survey" "MassGen" "No Insurance"
1010 "claims" "MassGen" "medicaid"
1011 "claims" "UPenn"   "Private Insurance"
1012 "EHR"    "MassGen" "No Insurance"
1015 "survey" "JHU"     "Medicaid"
end

* Convert to lowercase
gen insurance_lower = lower(insurance)

* First cleaning pass
gen clean_insurance = insurance
replace clean_insurance = "Private" if strpos(insurance_lower,"private")>0
replace clean_insurance = "Medicaid" if strpos(insurance_lower,"medicaid")>0

* Better solution: handle edge cases
replace clean_insurance = "Private" if insurance_lower=="privete insurance"
replace clean_insurance = "Uninsured" if insurance_lower=="no insurance"

list patient insurance clean_insurance, sepby(clean_insurance)

