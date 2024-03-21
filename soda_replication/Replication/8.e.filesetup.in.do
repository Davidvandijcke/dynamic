
global O  "$nhp"
global P  "$rs"
global P1 "$cd\FoodIn"

**************************************************************************
***Combine estimation result files
**************************************************************************

u "$O/FoodIn/logit_coefficients_group1_in.dta",clear

append using "$O/FoodIn/logit_coefficients_group2_in.dta"
append using "$O/FoodIn/logit_coefficients_group3_in.dta"
append using "$O/FoodIn/logit_coefficients_group4_in.dta"
append using "$O/FoodIn/logit_coefficients_group5_in.dta"

bysort dm: gen n = _n
gen dp = 0
gen z_price = coef_price/se_price
replace dp = 1 if z_price>1.96
drop if dp==1
drop n

preserve

drop se_* z_* drop

lab def rm 1 "Asda" 2 "Morrisons" 3 "Sainsburys" 4 "Tesco" 5 "Discounters" 6 "Other"
lab val rm rm

lab def orderA 1 "All products" 2 "Omits sugar products" 3 "Omits diet products" 4 "Omits non-sodas" 5 "Omits sugar and non-sodas" 6 "Omits diet and non-sodas"
lab val order orderA

order dmindex dm csindex hhtype order tm rm

lab var order              "Choice set index"                 
lab var hhtype             "Estimate index"
lab var dm                 "Decision index for estimation"
lab var coef_price         "Individual level coefficient"          
lab var coef_sugary        "Individual level coefficient"          
lab var coef_drinks        "Individual level coefficient"          
lab var coef_inv           "Inventory"          
lab var coef_size288       "Group level coefficient"             
lab var coef_size330       "Group level coefficient"             
lab var coef_size380       "Group level coefficient"             
lab var coef_size500       "Group level coefficient"             
lab var coef_size3         "Group level coefficient"             
lab var coef_size4         "Group level coefficient"             
lab var coef_size5         "Group level coefficient"             
lab var coef_size6         "Group level coefficient"             
lab var coef_size7         "Group level coefficient" 
lab var coef_size8         "Group level coefficient" 
lab var coef_bottle        "Group level coefficient"             
lab var coef_multi         "Group level coefficient"             
lab var coef_adstock       "Group level coefficient"       
lab var coef_drinkstmax    "Group level coefficient"       
lab var coef_drpepper      "Group level coefficient"             
lab var coef_fanta         "Group level coefficient"             
lab var coef_cherry        "Group level coefficient"             
lab var coef_oasis         "Group level coefficient"          
lab var coef_pepsi         "Group level coefficient"             
lab var coef_lucenergy     "Group level coefficient"             
lab var coef_ribena        "Group level coefficient"          
lab var coef_sprite        "Group level coefficient"          
lab var coef_irnbru        "Group level coefficient"          
lab var coef_other         "Group level coefficient"             
lab var coef_store         "Group level coefficient"             
lab var coef_fruit         "Group level coefficient"             
lab var coef_milk          "Group level coefficient"             
lab var coef_fruitwater    "Group level coefficient"
lab var coef_water         "Group level coefficient"          
lab var coef_coke_sm       "Group level coefficient"             
lab var coef_drpepper_sm   "Group level coefficient"              
lab var coef_fanta_sm      "Group level coefficient"             
lab var coef_cherry_sm     "Group level coefficient"             
lab var coef_pepsi_sm      "Group level coefficient"          
lab var coef_lucenergy_sm  "Group level coefficient"  
lab var coef_ribena_sm     "Group level coefficient"          
lab var coef_sprite_sm     "Group level coefficient"          
lab var coef_irnbru_sm     "Group level coefficient"          
lab var coef_other_sm      "Group level coefficient"          
lab var coef_water_sm      "Group level coefficient"          
lab var coef_coke_y        "Group level coefficient"
lab var coef_cokeoth_y     "Group level coefficient"
lab var coef_pepsico_y     "Group level coefficient"
lab var coef_gsk_y         "Group level coefficient"
lab var coef_barr_y        "Group level coefficient"
lab var coef_othsoda_y     "Group level coefficient"
lab var coef_othsug_y      "Group level coefficient"
lab var coef_water_y       "Group level coefficient"
lab var coef_coke_q        "Group level coefficient"
lab var coef_cokeoth_q     "Group level coefficient"
lab var coef_pepsico_q     "Group level coefficient"
lab var coef_gsk_q         "Group level coefficient"
lab var coef_barr_q        "Group level coefficient"
lab var coef_othsoda_q     "Group level coefficient"
lab var coef_othsug_q      "Group level coefficient"            
lab var coef_water_q       "Group level coefficient"
lab var coef_other_r       "Group level coefficient"          
lab var coef_store_r       "Group level coefficient"          
lab var coef_fruit_r       "Group level coefficient"          
lab var coef_water_r       "Group level coefficient"  
lab var coef_outside_r     "Group level coefficient"  
 
sa "$P/FoodIn/logit_coefficients.dta",replace

restore

bysort dm: keep if _n==1

keep dm hhno hhtype coef_price se_price coef_sugar se_sugar coef_drinks se_drinks sugar_prev order

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

sa "$P/FoodIn/coefs_consumer.dta",replace



**************************************
***Create data for pass-through
**************************************

u "$P/FoodIn/logit_coefficients.dta",clear

keep if product<1000 |product==99999
bysort csindex: gen N = _N
drop if N==1
drop N

gen coef_coke  = coef_coke_sm

foreach v in drpepper fanta cherry pepsi lucenergy ribena sprite irnbru other water {
	replace coef_`v' = coef_`v'+coef_`v'_sm
}
drop *_sm
drop size3-size8
drop coef_size3-coef_size8

sa "$P/FoodIn/logit_coefficients_small.dta",replace

u "$P1/prices.dta",clear

keep if prodagg<22

collapse (mean) price psize,by(prodagg rm year)

replace price=price*(0.5/psize) if prodagg==17|prodagg==19|prodagg==20|prodagg==21
replace psize = 0.5             if prodagg==17|prodagg==19|prodagg==20|prodagg==21

replace price=price*(0.33/psize) if prodagg==18
replace psize = 0.33             if prodagg==18

sa "$P/FoodIn/meanprice.dta",replace

u "$P/FoodIn/logit_coefficients_small.dta",clear

collapse (mean) drinks sugary inv size288 size330 size380 size500 bottle adstock drinkstmax coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water coef_coke_y coef_cokeoth_y coef_pepsico_y coef_gsk_y coef_barr_y coef_othsoda_y coef_othsug_y coef_water_y,by(hhtype order rm year product)

foreach v in coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y {
	rename coef_`v' `v'
}

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water {
	gen `v'_q = `v'
}

gen other_r = 0
replace other_r = 1 if product==31
gen fruit_r = 0
replace fruit_r = 1 if product==110
gen water_r = 0
replace water_r = 1 if product==140
gen outside_r = 0
replace outside_r = 1 if product==99999

gen     prodagg = 1  if product==1|product==3
replace prodagg = 2  if product==2|product==4
replace prodagg = 3  if product==5
replace prodagg = 4  if product==6
replace prodagg = 5  if product==9
replace prodagg = 6  if product==11
replace prodagg = 7  if product==12|product==13
replace prodagg = 8  if product==14
replace prodagg = 9  if product==16|product==18
replace prodagg = 10 if product==17|product==19
replace prodagg = 11 if product==20
replace prodagg = 12 if product==21
replace prodagg = 13 if product==22
replace prodagg = 14 if product==23
replace prodagg = 15 if product==26
replace prodagg = 16 if product==28|product==30
replace prodagg = 17 if product==31
replace prodagg = 18 if product==110
replace prodagg = 19 if product==120
replace prodagg = 20 if product==130
replace prodagg = 21 if product==140

merge m:1 prodagg rm year using "$P/FoodIn/meanprice.dta"
keep if _m==3|product==99999
drop _m prodagg

replace psize = 0 if product==99999
replace price = 0 if product==99999

rename psize size

sa "$P/FoodIn/groupXmatrix_begin.dta",replace

u "$P/FoodIn/groupXmatrix_begin.dta",clear

gen soda = product<100
replace size = 0 if soda!=1 | sugary!=1

**_t
keep  rm year hhtype order product price drinks sugary inv size288 size330 size380 size500 bottle  adstock drinkstmax coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water other_r fruit_r water_r outside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q size hhtype     
order rm year hhtype order product price drinks sugary inv size288 size330 size380 size500 bottle adstock drinkstmax coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water other_r fruit_r water_r outside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q size hhtype
sort  rm year hhtype order product

rename outside_r nonoutside_r

sa "$P/FoodIn/groupXmatrix.dta",replace

u "$P/FoodIn/groupXmatrix_begin.dta",clear

gen soda = product<100
replace size = 0 if soda!=1 

**_t
keep  rm year hhtype order product price drinks sugary inv size288 size330 size380 size500 bottle  adstock drinkstmax  coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water other_r fruit_r water_r outside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q size hhtype    
order rm year hhtype order product price drinks sugary inv size288 size330 size380 size500 bottle adstock drinkstmax  coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water other_r fruit_r water_r outside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q size hhtype
sort  rm year hhtype order product

rename outside_r nonoutside_r

sa "$P/FoodIn/groupXmatrix2.dta",replace

u "$P/FoodIn/logit_coefficients_small.dta",clear

keep if choice==1
 
keep csindex rm year hhtype order coef_price coef_drinks coef_sugary

set seed 89
drawnorm x

sort hhtype order year x
by hhtype order year: gen n = _n
keep if n<251

keep csindex rm year hhtype order coef_price coef_drinks coef_sugary

foreach v in price sugary drinks {
	replace coef_`v' = 0 if coef_`v'==.
}

order rm year hhtype order
sort  rm year hhtype order

sa "$P/FoodIn/groupXCoefdraws.dta",replace

u "$P/FoodIn/logit_coefficients_small.dta",clear

keep if choice==1

collapse (mean) coef_inv coef_size288 coef_size330 coef_size380 coef_size500 coef_bottle coef_adstock coef_drinkstmax coef_coke coef_drpepper coef_fanta coef_cherry coef_oasis coef_pepsi coef_lucenergy coef_ribena coef_sprite coef_irnbru coef_other coef_fruit coef_milk coef_fruitwater coef_water coef_other_r coef_fruit_r coef_water_r coef_outside_r coef_coke_q coef_cokeoth_q coef_pepsico_q coef_gsk_q coef_barr_q coef_othsoda_q coef_othsug_q coef_water_q,by(hhtype)

foreach v in coef_coke_y coef_cokeoth_y coef_pepsico_y coef_gsk_y coef_barr_y coef_othsoda_y coef_othsug_y coef_water_y {
	gen `v' = 1
}

rename coef_outside_r coef_nonoutside_r

sa "$P/FoodIn/groupFixedcoef.dta",replace

u "$P/FoodIn/logit_coefficients_small.dta",clear

bysort dm rm year: keep if _n==1

gen weight = 1
collapse (sum) weight,by(rm year hhtype order)

egen base = sum(weight),by(rm year)
replace weight = weight/base
drop base

sort rm year hhtype order

sa "$P/FoodIn/weights.dta",replace
