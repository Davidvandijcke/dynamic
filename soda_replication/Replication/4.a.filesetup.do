
global O  "$nhp"
global P  "$rs"

**************************************************************************
***Combine estimation result files
**************************************************************************

**Combine male and female estimates

u "$O/logit_coefficients_group1.dta",clear

append using "$O/logit_coefficients_group2.dta"
append using "$O/logit_coefficients_group3.dta"
append using "$O/logit_coefficients_group4.dta"

bysort dm: gen n = _n
gen dp = 0
gen z_price = coef_price/se_price
replace dp = 1 if z_price>1.96
centile coef_price if n==1 & dp==0, centile(0.5 99.5)
replace dp = 1 if coef_price<r(c_1)|coef_price>r(c_2)
drop if dp==1
drop n

preserve

drop se_* z_* dp

cap lab def rm 1 "National-large" 2 "National-small" 3 "Vending machine" 4 "South" 5 "Midlands" 6 "North"
lab val rm rm

lab def orderA 1 "All products" 2 "Omits sugar products" 3 "Omits diet products"
lab val order orderA

lab def group 1 "Female, young" 2 "Female, old" 3 "Male, young" 4 "Male, old"
lab val group

order dmindex dm csindex group order tm rm

lab var order             "Choice set index"                 
lab var group             "Estimate index"
lab var dm                "Decision index for estimation"
lab var coef_price        "Individual level coefficient"          
lab var coef_drinks       "Individual level coefficient"         
lab var coef_sugary       "Individual level coefficient"          
lab var coef_inv          "Group level coefficient"               
lab var coef_size288      "Group level coefficient"          
lab var coef_size330      "Group level coefficient"          
lab var coef_size380      "Group level coefficient"
lab var coef_adstock      "Group level coefficient"               
lab var coef_drinkstmax   "Group level coefficient" 
lab var coef_drpepper     "Group level coefficient"          
lab var coef_fanta        "Group level coefficient"          
lab var coef_cherry       "Group level coefficient"          
lab var coef_oasis        "Group level coefficient"          
lab var coef_pepsi        "Group level coefficient"          
lab var coef_lucenergy    "Group level coefficient"          
lab var coef_ribena       "Group level coefficient" 
lab var coef_sprite       "Group level coefficient"               
lab var coef_irnbru       "Group level coefficient"               
lab var coef_other        "Group level coefficient"          
lab var coef_fruit        "Group level coefficient"          
lab var coef_milk         "Group level coefficient"          
lab var coef_fruitwater   "Group level coefficient"          
lab var coef_water        "Group level coefficient"
lab var coef_sugoutside   "Group level coefficient"                                   
lab var coef_coke_y       "Group level coefficient"
lab var coef_cokeoth_y    "Group level coefficient"
lab var coef_pepsico_y    "Group level coefficient"
lab var coef_gsk_y        "Group level coefficient"
lab var coef_barr_y       "Group level coefficient"               
lab var coef_othsoda_y    "Group level coefficient"
lab var coef_othsug_y     "Group level coefficient"
lab var coef_water_y      "Group level coefficient"
lab var coef_sugoutside_y "Group level coefficient"                                  
lab var coef_coke_q       "Group level coefficient"
lab var coef_cokeoth_q    "Group level coefficient"
lab var coef_pepsico_q    "Group level coefficient"
lab var coef_gsk_q        "Group level coefficient"
lab var coef_barr_q       "Group level coefficient"              
lab var coef_othsoda_q    "Group level coefficient"
lab var coef_othsug_q     "Group level coefficient"
lab var coef_water_q      "Group level coefficient"               
lab var coef_sugoutside_q "Group level coefficient"                 
lab var coef_other_r      "Group level region coefficient"      
lab var coef_fruit_r      "Group level region coefficient"      
lab var coef_water_r      "Group level region coefficient"      
lab var coef_sugoutside_r "Group level region coefficient"                 
lab var coef_nonoutside_r "Group level region coefficient"   
lab var tm                "Year-month"

sa "$P/logit_coefficients.dta",replace

restore

bysort dm: keep if _n==1

keep dm hhno indvno group coef_price se_price coef_sugar se_sugar coef_drinks se_drinks sugar_prev indrink order

foreach v in price sugar drinks {
    gen z_`v' = coef_`v'/se_`v'
}

lab var coef_price       "Individual level coefficient"          
lab var coef_sugary      "Individual level coefficient"          
lab var coef_drinks      "Individual level coefficient"          

lab var se_price       "Standard error"          
lab var se_sugary      "Standard error"          
lab var se_drinks      "Standard error"          

lab var z_price  "z-score"
lab var z_sugar  "z-score"
lab var z_drinks "z-score"

sa "$P/coefs_consumer.dta",replace

**Outsheet files of MatLab estimates code

u "$O/logit_coefficients_group1.dta",clear

append using "$O/logit_coefficients_group2.dta"
append using "$O/logit_coefficients_group3.dta"
append using "$O/logit_coefficients_group4.dta"

bysort dm: keep if _n==1
gen dp = 0
gen z_price = coef_price/se_price
replace dp = 1 if z_price>1.96
centile coef_price if dp==0, centile(0.5 99.5)
replace dp = 1 if coef_price<r(c_1)|coef_price>r(c_2)

sort dm

keep dm dp indrink coef_drinks coef_sugar group

sa "$P/dropindex.dta",replace

u "$P/dropindex.dta",clear

sort dm
outsheet dp using "$O/coef_price_index.raw",comma replace non
foreach n of numlist 1(1)4 {
    outsheet dp using "$O/coef_price_index`n'.raw" if group==`n',comma replace non
}

u "$P/dropindex.dta",clear

keep if indrink==1

sort dm
outsheet dp using "$O/coef_soda_index.raw",comma replace non
foreach n of numlist 1(1)4 {
    outsheet dp using "$O/coef_soda_index`n'.raw" if group==`n',comma replace non
}

u "$P/dropindex.dta",clear

keep if coef_sugar!=.

sort dm
outsheet dp using "$O/coef_sugar_index.raw",comma replace non
foreach n of numlist 1(1)4 {
    outsheet dp using "$O/coef_sugar_index`n'.raw" if group==`n',comma replace non
}

u "$P/dropindex.dta",clear

keep if indrink==1 & coef_sugar!=.

sort dm
outsheet dp using "$O/coef_sodasugar_index.raw",comma replace non
foreach n of numlist 1(1)4 {
    outsheet dp using "$O/coef_sodasugar_index`n'.raw" if group==`n',comma replace non
}

**************************************************************************
***Files for confidence bands
**************************************************************************

u "$P/coefs_consumer.dta",clear

keep dm 

sa "$P/trim_forpricef.dta",replace

forval z =1/4 {

    u "$OX/logit_coefficients_group`z'.dta",clear

    keep if choice==1

    keep csindex hhno indvno year group order

    sa "$O/cs_group`z'",replace

}
