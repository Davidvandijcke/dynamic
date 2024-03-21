
global P0 "$cd"
global P  "$rs"

****************************************************************
***Prepare data for Matlab
****************************************************************

u "$P0/snackpurchases_raw.dta",clear

replace product = 199 if cat==2
replace product = 999 if cat==3

gen     storetype2 = 1 if index(lower(fascia),"asda")>0
replace storetype2 = 2 if index(lower(fascia),"morrisons")>0
replace storetype2 = 3 if index(lower(fascia),"sainsbury")>0
replace storetype2 = 4 if index(lower(fascia),"tesco")>0
replace storetype2 = 5 if index(lower(fascia),"aldi")>0|index(lower(fascia),"lidl")>0
replace storetype2 = 6 if storetype2==.

gen     rmcount = storetype2
replace rmcount = 7  if storetype==2
replace rmcount = 8  if storetype==3
replace rmcount = 9  if rm==4
replace rmcount = 10 if rm==5
replace rmcount = 11 if rm==6

lab def rmcount 1  "Asda" 2  "Morrisons" 3  "Sainsbury's" 4  "Tesco" 5  "Discounter" 6  "Other national large" 7  "National small" 8  "Vending machines" 9  "Regional - south" 10 "Regional - midlands" 11 "Regional - north"
lab val rmcount rmcount

collapse (sum) exp,by(hhno indvno date product rmcount)

sort hhno indvno date product rmcount
set seed 45
drawnorm x
gen temp = -exp
sort hhno indvno date product temp x
bysort hhno indvno date product: keep if _n==1
drop temp exp x

merge 1:1 hhno indvno date product using "$P0/all_purchases.dta",keepusing(csindex rm)
keep if _m==3
drop _m

replace rmcount = 7  if rm==2
replace rmcount = 8  if rm==3 
replace rmcount = 9  if rm==4 
replace rmcount = 10 if rm==5
replace rmcount = 11 if rm==6

keep csindex rmcount

sa "$P/Passthrough/counterfacutalrm.dta",replace

u "$P/coefs_consumer.dta",clear

centile coef_price,centile(10 90)
drop if coef_price<r(c_1) | coef_price>r(c_2)

keep hhno indvno 

sa "$P/Passthrough/individuals.dta",replace


u "$P/logit_coefficients.dta",clear

keep if choice==1

merge 1:1 csindex using "$P/Passthrough/counterfacutalrm.dta"
keep if _m==3
drop _m
 
merge m:1 hhno indvno using "$P/Passthrough/individuals.dta"
keep if _m==3
drop _m
 
keep csindex rmcount year group order coef_price coef_drinks coef_sugary
rename rmcount rm

set seed 89
drawnorm x

sort order rm year x
by order rm year: gen n = _n
keep if n<251

keep csindex rm year group order coef_price coef_drinks coef_sugary

foreach v in price drinks sugary {
	replace coef_`v' = 0 if coef_`v'==.
}

order rm year group order
sort  rm year group order

sa "$P/Passthrough/groupXCoefdraws_out.dta",replace

u "$P/Passthrough/groupXCoefdraws_out.dta",clear

gen out = 1

append using "$P/FoodIn/groupXCoefdraws.dta"
replace out = 2 if out==.

su group if out==1
local l = r(max)
replace group = hhtype+`l' if out==2
sort group

drop hhtype 

egen sub = group(rm year group order)

order sub 
sort sub 
	
sa "$P/Passthrough/groupXCoefdraws.dta",replace

u "$P/Passthrough/groupXCoefdraws.dta",clear

keep sub rm year order group out
bysort sub: keep if _n==1

sa "$P/Passthrough/submapping.dta",replace


u "$P/FoodIn/meanprice.dta",clear

label drop prodagg
rename prodagg prodagg_o
gen     prodagg = 1 if prodagg_o==1
replace prodagg = 2 if prodagg_o==2
replace prodagg = 3 if prodagg_o==3
replace prodagg = 4 if prodagg_o==4
replace prodagg = 6 if prodagg_o==5
replace prodagg = 7 if prodagg_o==6
replace prodagg = 8 if prodagg_o==7
replace prodagg = 9 if prodagg_o==8
replace prodagg = 10 if prodagg_o==9
replace prodagg = 11 if prodagg_o==10
replace prodagg = 12 if prodagg_o==11
replace prodagg = 13 if prodagg_o==12
replace prodagg = 14 if prodagg_o==13
replace prodagg = 15 if prodagg_o==14
replace prodagg = 17 if prodagg_o==15
replace prodagg = 19 if prodagg_o==16
replace prodagg = 20 if prodagg_o==17
replace prodagg = 22 if prodagg_o==18
replace prodagg = 23 if prodagg_o==19
replace prodagg = 24 if prodagg_o==20
replace prodagg = 25 if prodagg_o==21
drop prodagg_o

sa "$P/Passthrough/meanpriceA.dta",replace

forv r=1/6 {
  u "$P0/prices.dta",clear
  
  keep if rm==1

  collapse (mean) price_smooth,by(prodagg year)

  gen rm=`r'

  merge 1:1 prodagg year rm using "$P/Passthrough/meanpriceA.dta"
  keep if rm==`r'
  replace price_smooth = price if _m!=1
  drop price _m

  rename price_smooth price 
  drop psize
  
  sa "$P/Passthrough/meanpriceB`r'.dta",replace
}

u "$P0/prices.dta",clear

collapse (mean) price_smooth,by(prodagg rm year)

drop if rm==1

rename price_smooth price

replace rm = rm+5

forv r=1/6{
	append using "$P/Passthrough/meanpriceB`r'.dta"
}

sort rm year prodagg

cap lab def rmcount 1  "Asda" 2  "Morrisons" 3  "Sainsbury's" 4  "Tesco" 5  "Discounter" 6  "Other national large" 7  "National small" 8  "Vending machines" 9  "Regional - south" 10 "Regional - midlands" 11 "Regional - north"
lab val rm rmcount

sa "$P/Passthrough/meanprice.dta",replace

u "$P/logit_coefficients.dta",clear
 
merge m:1 csindex using "$P/Passthrough/counterfacutalrm.dta"
keep if _m==3
drop _m
 
collapse (mean) drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside  coke cokeoth pepsico gsk barr othsoda othsug coef_coke_y coef_cokeoth_y coef_pepsico_y coef_gsk_y coef_barr_y coef_othsoda_y coef_othsug_y coef_water_y coef_sugoutside_y,by(group order rmcount year product)
rename rmcount rm

foreach v in coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y {
	rename coef_`v' `v'
}

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water sugoutside  {
	gen `v'_q = `v'
}
drop coke cokeoth pepsico gsk barr othsoda othsug 

gen other_r = 0
replace other_r = 1 if product==25|product==26
gen fruit_r = 0
replace fruit_r = 1 if product==110
gen water_r = 0
replace water_r = 1 if product==140
gen sugoutside_r = 0
replace sugoutside_r = 1 if product==199
gen nonoutside_r = 0
replace nonoutside_r = 1 if product==999

gen     prodagg = 1  if product==1|product==3
replace prodagg = 2  if product==2|product==4
replace prodagg = 3  if product==5
replace prodagg = 4  if product==6|product==7
replace prodagg = 5  if product==8
replace prodagg = 6  if product==9|product==10
replace prodagg = 7  if product==11
replace prodagg = 8  if product==12|product==13
replace prodagg = 9  if product==14|product==15
replace prodagg = 10 if product==16|product==18
replace prodagg = 11 if product==17|product==19
replace prodagg = 12 if product==20
replace prodagg = 13 if product==21
replace prodagg = 14 if product==22
replace prodagg = 15 if product==23|product==24
replace prodagg = 16 if product==25
replace prodagg = 17 if product==26
replace prodagg = 18 if product==27|product==29
replace prodagg = 19 if product==28|product==30
replace prodagg = 20 if product==31
replace prodagg = 21 if product==32

replace prodagg = 22 if product==110
replace prodagg = 23 if product==120
replace prodagg = 24 if product==130
replace prodagg = 25 if product==140

merge m:1 prodagg rm year using "$P/Passthrough/meanprice.dta" 
drop if _m==2
replace price = 0 if product==199|product==999

egen temp = mean(price),by(prodagg year)
replace price = temp if price==.
drop _m prodagg temp

sa "$P/Passthrough/groupXmatrix_begin.dta",replace

u "$P/Passthrough/groupXmatrix_begin.dta",clear

gen     size = 0.5  
replace size = 0.288 if size288==1
replace size = 0.33  if size330==1
replace size = 0.38  if size380==1
replace size = 0     if product>100 | sugary!=1

**_t 
keep rm year group order product price drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group  
order rm year group order product price drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group  
sort rm year group order product 

sa "$P/Passthrough/groupXmatrix_out.dta",replace

u "$P/Passthrough/groupXmatrix_out.dta",replace

drop size

gen     size = 0.5   
replace size = 0.288 if size288==1
replace size = 0.33  if size330==1
replace size = 0.38  if size380==1
replace size = 0     if product>100

**_t
keep rm year group order product price drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group  
order rm year group order product price drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group  
sort rm year group order product 

sa "$P/Passthrough/groupXmatrix2_out.dta",replace

u "$P/logit_coefficients.dta",clear

keep if choice==1
 
collapse (mean) coef_inv coef_size288 coef_size330 coef_size380 coef_adstock coef_drinkstmax coef_drpepper coef_fanta coef_cherry coef_oasis coef_pepsi coef_lucenergy coef_ribena coef_sprite coef_irnbru coef_other coef_fruit coef_milk coef_fruitwater coef_water coef_sugoutside coef_other_r coef_fruit_r coef_water_r coef_sugoutside_r coef_nonoutside_r coef_coke_q coef_cokeoth_q coef_pepsico_q coef_gsk_q coef_barr_q coef_othsoda_q coef_othsug_q coef_water_q coef_sugoutside_q,by(group)

foreach v in coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y {
	gen coef_`v' = 1
}

sa "$P/Passthrough/groupFixedcoef_out.dta",replace

u "$P/Passthrough/groupXmatrix_out.dta",replace

gen out = 1

append using "$P/FoodIn/groupXmatrix.dta"
replace out = 2 if out==.

replace product=999 if product==99999

su group if out==1
local l = r(max)
replace group = hhtype+`l' if out==2

merge m:1 order rm year group using "$P/Passthrough/submapping.dta"
keep if _m==3
drop hhtype out _m

foreach v in inv size500 bottle coke sugoutside sugoutside_r sugoutside_y sugoutside_q {
	replace `v' = 0 if `v'==.
}

egen opt = group(product)
drop order product

egen market = group(rm year)

gen sub2 = sub

keep  sub sub2 opt market price drinks sugary inv size288 size330 size380 size500 bottle adstock drinkstmax coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group     
order sub sub2 opt market price drinks sugary inv size288 size330 size380 size500 bottle adstock drinkstmax coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group     
sort sub opt

sa "$P/Passthrough/groupXmatrix.dta",replace

u "$P/Passthrough/groupXmatrix2_out.dta",replace

gen out = 1

append using "$P/FoodIn/groupXmatrix2.dta"
replace out = 2 if out==.

replace product=999 if product==99999

su group if out==1
local l = r(max)
replace group = hhtype+`l' if out==2

merge m:1 order rm year group using "$P/Passthrough/submapping.dta"
keep if _m==3
drop hhtype out _m

foreach v in inv size500 bottle coke sugoutside sugoutside_r sugoutside_y sugoutside_q {
	replace `v' = 0 if `v'==.
}

egen opt = group(product)
drop order product

egen market = group(rm year)

gen sub2 = sub

keep  sub sub2 opt market price drinks sugary inv size288 size330 size380 size500 bottle adstock drinkstmax coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group     
order sub sub2 opt market price drinks sugary inv size288 size330 size380 size500 bottle adstock drinkstmax coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r fruit_r water_r sugoutside_r nonoutside_r coke_y cokeoth_y pepsico_y gsk_y barr_y othsoda_y othsug_y water_y sugoutside_y coke_q cokeoth_q pepsico_q gsk_q barr_q othsoda_q othsug_q water_q sugoutside_q size group     
sort sub opt

sa "$P/Passthrough/groupXmatrix2.dta",replace


u "$P/Passthrough/groupFixedcoef_out.dta",clear

gen out = 1

append using "$P/FoodIn/groupFixedcoef.dta"
replace out = 2 if out==.

su group if out==1
local l = r(max)
replace group = hhtype+`l' if out==2

drop hhtype out 

foreach v in coef_inv coef_size500 coef_bottle coef_coke coef_sugoutside coef_sugoutside_r coef_sugoutside_y coef_sugoutside_q{
	replace `v' = 0 if `v'==.
}

sort group
order group coef_inv coef_size288 coef_size330 coef_size380 coef_size500 coef_bottle coef_adstock coef_drinkstmax coef_coke coef_drpepper coef_fanta coef_cherry coef_oasis coef_pepsi coef_lucenergy coef_ribena coef_sprite coef_irnbru coef_other coef_fruit coef_milk coef_fruitwater coef_water coef_sugoutside coef_other_r coef_fruit_r coef_water_r coef_sugoutside_r coef_nonoutside_r coef_coke_y coef_cokeoth_y coef_pepsico_y coef_gsk_y coef_barr_y coef_othsoda_y coef_othsug_y coef_water_y coef_sugoutside_y coef_coke_q coef_cokeoth_q coef_pepsico_q coef_gsk_q coef_barr_q coef_othsoda_q coef_othsug_q coef_water_q coef_sugoutside_q
keep group coef_inv coef_size288 coef_size330 coef_size380 coef_size500 coef_bottle coef_adstock coef_drinkstmax coef_coke coef_drpepper coef_fanta coef_cherry coef_oasis coef_pepsi coef_lucenergy coef_ribena coef_sprite coef_irnbru coef_other coef_fruit coef_milk coef_fruitwater coef_water coef_sugoutside coef_other_r coef_fruit_r coef_water_r coef_sugoutside_r coef_nonoutside_r coef_coke_y coef_cokeoth_y coef_pepsico_y coef_gsk_y coef_barr_y coef_othsoda_y coef_othsug_y coef_water_y coef_sugoutside_y coef_coke_q coef_cokeoth_q coef_pepsico_q coef_gsk_q coef_barr_q coef_othsoda_q coef_othsug_q coef_water_q coef_sugoutside_q

sa "$P/Passthrough/groupFixedcoef.dta",replace

u "$P/Passthrough/groupXCoefdraws.dta",clear

gen i = 1

collapse (sum) i,by(sub)

gen out = 1

sort sub

sa "$P/Passthrough/drawnumber.dta",replace

u "$P/logit_coefficients.dta",clear
 
drop rm
merge m:1 csindex using "$P/Passthrough/counterfacutalrm.dta"
keep if _m==3
drop _m
rename rmcount rm

bysort dm rm year: keep if _n==1

gen weight = 1
collapse (sum) weight,by(rm year group order)

egen base = sum(weight),by(rm year)
replace weight = weight/base
drop base

gen out = 1
append using "$P/FoodIn/weights.dta"
replace out = 2 if out==.

su group if out==1
local l = r(max)
replace group = hhtype+`l' if out==2

merge m:1 order rm year group using "$P/Passthrough/submapping.dta"
keep if _m==3
drop hhtype _m

replace weight = weight*(1-.086) if out==1
replace weight = weight*.086     if out==2

drop out

sort rm year group order

sa "$P/Passthrough/weights.dta",replace

outsheet weight using "$P/Passthrough/weights.raw",comma non nol replace

u "$P/Passthrough/groupXmatrix2.dta",clear

keep opt market price size sugary other 
bysort opt market: keep if _n==1

gen     simvA = 0
replace simvA = size*sugary if opt<33

gen     simvB = 0
replace simvB = size if opt<33

gen fixed = opt>30

keep opt market price simvA simvB fixed

collapse (sum) price (min) simvA simvB fixed,by(opt market)

reshape wide price simvA simvB fixed,i(opt) j(market)

sa "$P/Passthrough/marketvars.dta",replace


u "$P/Passthrough/groupXmatrix.dta",clear

bysort sub: keep if _n==1
keep sub market

sa "$P/Passthrough/marmap.dta",replace
 
forval m=1/66 {

 global Ps "$P/Passthrough/`m'"
 capture confirm file "$Ps/nul"
 if _rc>0 {
	mkdir "$Ps"
 }

 u  "$P/Passthrough/groupFixedcoef.dta",clear

 drop group
 outsheet using "$Ps/groupFixedcoef.raw",comma non nol replace


 u "$P/Passthrough/groupXCoefdraws.dta",clear

 egen market = group(rm year)
 keep if market==`m'
 
 egen subN = group(sub)
 drop sub

 outsheet sub coef_price coef_drinks coef_sugary using "$Ps/groupXCoefdraws.raw",comma non nol replace


 u "$P/Passthrough/groupXmatrix.dta",clear

 keep if market==`m'

 keep opt sub
 egen optN = group(opt)
 egen subN = group(sub)

 sa "$Ps/opmap.dta",replace

 u "$P/Passthrough/groupXmatrix.dta",clear

 keep if market==`m'
 replace market = 1

 egen optN = group(op)
 egen subN = group(sub)
 gen subN2=subN
 drop sub sub2 opt
 order subN subN2 optN

 outsheet using "$Ps/groupXmatrix.raw",comma non nol replace


 u "$P/Passthrough/groupXmatrix2.dta",clear

 keep if market==`m'
 replace market = 1

 egen optN = group(op)
 egen subN = group(sub)
 gen subN2=subN
 drop sub sub2 opt
 order subN subN2 optN

 outsheet using "$Ps/groupXmatrix2.raw",comma non nol replace

 u "$P/Passthrough/drawnumber.dta",clear

 merge 1:1 sub using "$P/Passthrough/marmap.dta"
 drop _m
 
 egen subN = group(sub)
 drop sub

 keep if market==`m'

 outsheet i using "$Ps/drawnumber.raw",comma non nol replace


 u "$P/Passthrough/weights.dta",clear

 egen market = group(rm year)
 keep if market==`m'

 outsheet weight using "$Ps/weights.raw",comma non nol replace


 u "$P/Passthrough/marketvars.dta",clear
 
 drop if price`m'==.

 outsheet price`m' fixed`m' using "$Ps/prices.raw",comma non nol replace
 outsheet simvA`m' using "$Ps/simv1.raw",comma non nol replace
 outsheet simvB`m' using "$Ps/simv2.raw",comma non nol replace

 u "$P0/attributes.dta",clear
 egen opt = group(product)
 egen man = group(firm)
 egen br = group(brand)

 bysort op: keep if _n==1

 merge 1:m op using "$P/Passthrough/groupXmatrix.dta"
 drop if _m==1
 drop _m
 
 foreach v in opt br  {
	replace `v' = 999 if `v'==.
 }
 replace man = 5 if man==.	

 keep if market==`m'
 bysort opt: keep if _n==1

 egen optN = group(opt)
 egen manN = group(man)
 egen brN  = group(br)

 keep  optN brN manN
 order optN brN manN

 sort op

 outsheet using "$Ps/ownership_data.raw",comma nol non replace

}
