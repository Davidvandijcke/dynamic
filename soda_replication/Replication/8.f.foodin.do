global P0 "$cd"
global P  "$rs"
global P2 "$ds"

u "$P/FoodIn/logit_coefficients.dta",clear

gen diet = 1-sugary
merge m:1 brand diet using "$P2/sugars_prod.dta"
tab brand diet if sugars==.
replace sugars = 0  if sugars==. & (diet==1|product==99999)
replace sugars = 10 if sugars==. & diet==0
drop if _m==2
drop _m

global Avars = "price drinks sugary inv size288 size330 size380 size500 size3 size4 size5 size6 size7 size8 bottle multi adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater water coke_sm drpepper_sm fanta_sm cherry_sm pepsi_sm lucenergy_sm ribena_sm sprite_sm irnbru_sm other_sm water_sm"
global Bvars = "price drinks	   inv size288 size330 size380 size500 size3 size4 size5 size6 size7 size8 bottle multi adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater coke_sm drpepper_sm fanta_sm cherry_sm pepsi_sm lucenergy_sm ribena_sm sprite_sm irnbru_sm other_sm water_sm"
global Cvars = "price drinks       inv size288 size330 size380 size500 size3 size4 size5 size6 size7 size8 bottle multi adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater coke_sm drpepper_sm fanta_sm cherry_sm pepsi_sm lucenergy_sm ribena_sm sprite_sm irnbru_sm other_sm water_sm"
global rvars = "other store fruit water outside"
**global tvars = ""
global tvars = "coke cokeoth pepsico gsk barr othsoda othsug water"
 
cap prog drop predictshr
prog def predictshr 
 gen V = 0
 foreach v in $Avars {
     qui replace V = V+`v'*coef_`v' if order==1
 }
 foreach v in $Bvars {
     qui replace V = V+`v'*coef_`v' if order==2
 }
 foreach v in $Cvars {
     qui replace V = V+`v'*coef_`v' if order==3
 }
  foreach v in $rvars {
     qui replace V = V+`v'*coef_`v'_r
 }
 foreach v in $tvars {
     qui replace V = V+`v'*coef_`v'_y+`v'*coef_`v'_q
 }
 gen eV=exp(V)
 egen den = sum(eV),by(csindex)
 gen prob = eV/den
 drop eV den
end 

gen pre_price = price
predictshr
rename prob pre_prob
drop V

gen soda = product!=110&product!=120&product!=130&product!=140&product<99000

replace price = price+psize*0.25 if soda==1
predictshr
rename prob post_prob
drop V

gen post_price = price
drop price

keep dmindex dm csindex hhtype order hhno day week month year product pre_price post_price soda sugary pre_prob post_prob psize sugars

rename psize size

gen pre_tot_sug_in  = pre_prob*size*sugars*10
gen post_tot_sug_in = post_prob*size*sugars*10

collapse (sum) *_sug_in,by(hhno year)

merge m:1 hhno year using "$P2/weekindata.dta"
keep if _m==3
drop _m

replace pre_tot_sug_in  = pre_tot_sug_in*(54/obs)
replace post_tot_sug_in = post_tot_sug_in*(54/obs)

sa "$P/priceeffects_fi.dta",replace

u "$P2/purchyearfull.dta",clear

merge m:1 hhno indvno using "$P0/indvno_sample.dta"
keep if _m==3 
drop _m 

keep hhno indvno year agecat sodapurch indemand hheqsize 

merge m:1 hhno year using "$P/priceeffects_fi.dta" 
egen max = max(_m),by(hhno indvno)
drop if max==2
sort hhno year
forval x = 1/4{
 foreach v in agecat sodapurch indemand {
	by hhno: replace `v' = `v'[_n-`x'] if max==3 & _m==1 & `v'==.
	by hhno: replace `v' = `v'[_n+`x'] if max==3 & _m==1 & `v'==.
 }	
}
replace pre_tot_sug_in  = 0 if max==1
replace post_tot_sug_in = 0 if max==1

replace pre_tot_sug_in  = pre_tot_sug_in/hheqsize
replace post_tot_sug_in = post_tot_sug_in/hheqsize

drop max _m

merge 1:1 hhno indvno year using "$P/tax_predictions_demogs.dta",keepusing(pre_drk_sug post_UK_drk_sug)
drop _m

replace pre_drk_sug     = 0 if pre_drk_sug==.
replace post_UK_drk_sug = 0 if post_UK_drk_sug==.

collapse (mean) pre_tot_sug_in post_tot_sug_in pre_drk_sug post_UK_drk_sug,by(agecat year)
collapse (mean) pre_tot_sug_in post_tot_sug_in pre_drk_sug post_UK_drk_sug,by(agecat)

gen delta_in  = post_tot_sug_in-pre_tot_sug_in
gen delta_out = post_UK_drk_sug-pre_drk_sug

foreach v in in out {
	gen  temp1 = delta_`v' if agecat==1
	egen temp2 = min(temp1)
	replace delta_`v' = delta_`v'/temp2
	drop temp*
}

keep agecat delta_in delta_out 

sa "$P/athome_age.dta",replace
