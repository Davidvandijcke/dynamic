global P  "$rs"

**************************************************
***Log coef
**************************************************

u "$P/logit_coefficients.dta",clear

drop coef_*

merge m:1 dm using "$P/MonteCarlo/pdraw.dta",keepusing(v$N)
drop _m
rename v$N coef_price

merge m:1 dm using "$P/MonteCarlo/xdraw.dta",keepusing(v$N)
drop _m
rename v$N coef_drinks

merge m:1 dm using "$P/MonteCarlo/ydraw.dta",keepusing(v$N)
drop _m
rename v$N coef_sugary

foreach x of numlist 1(1)22 {
    gen fcoef = `x'
    merge m:1 group fcoef using "$P/MonteCarlo/fdraw.dta",keepusing(v$N)
	drop if _m==2
    drop _m

    rename v$N fc`x'
    drop fcoef
}

rename fc1  coef_inv
rename fc2  coef_size288
rename fc3  coef_size330
rename fc4  coef_size380
rename fc5  coef_adstock
rename fc6  coef_drinkstmax
rename fc7  coef_drinks_res
rename fc8  coef_drpepper
rename fc9  coef_fanta
rename fc10 coef_cherry
rename fc11 coef_oasis
rename fc12 coef_pepsi
rename fc13 coef_lucenergy
rename fc14 coef_ribena
rename fc15 coef_sprite
rename fc16 coef_irnbru
rename fc17 coef_other
rename fc18 coef_fruit
rename fc19 coef_milk
rename fc20 coef_fruitwater
rename fc21 coef_water
rename fc22 coef_sugoutside

foreach x of numlist 1(1)9 {
    gen brd = `x'
    merge m:1 group brd year using "$P/MonteCarlo/adraw.dta",keepusing(v$N)
    drop if _m==2
    drop _m

    rename v$N bc`x'
    drop brd
}

rename bc1 coef_coke_y
rename bc2 coef_cokeoth_y
rename bc3 coef_pepsico_y
rename bc4 coef_gsk_y
rename bc5 coef_barr_y
rename bc6 coef_othsoda_y
rename bc7 coef_othsug_y
rename bc8 coef_water_y
rename bc9 coef_sugoutside_y

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water sugoutside {
	replace coef_`v'_y = 0 if year==2009
}

foreach x of numlist 1(1)9 {
    gen brd = `x'
    merge m:1 group brd quarter using "$P/MonteCarlo/qdraw.dta",keepusing(v$N)
    drop if _m==2
    drop _m

    rename v$N bc`x'
    drop brd
}

rename bc1 coef_coke_q
rename bc2 coef_cokeoth_q
rename bc3 coef_pepsico_q
rename bc4 coef_gsk_q
rename bc5 coef_barr_q
rename bc6 coef_othsoda_q
rename bc7 coef_othsug_q
rename bc8 coef_water_q
rename bc9 coef_sugoutside_q

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water sugoutside {
	replace coef_`v'_q = 0 if quarter==1
}

foreach x of numlist 1(1)5 {
    gen out = `x'
    merge m:1 group out rm using "$P/MonteCarlo/rdraw.dta",keepusing(v$N)
    drop if _m==2
    drop _m

    rename v$N oc`x'
    drop out
}

rename oc1 coef_other_r
rename oc2 coef_fruit_r
rename oc3 coef_water_r
rename oc4 coef_sugoutside_r
rename oc5 coef_nonoutside_r

foreach v in other fruit water sugoutside nonoutside {
    replace coef_`v'_r = 0 if rm==1
}

sort dm csindex product tm

forv x = 1/4 {
	su coef_drinks_res if group==`x'
	local l = r(mean)
	replace coef_drinks = `l' if coef_drinks==. & group==`x'
}

drop coef_drinks_res

sa "$P/MonteCarlo/$N/log_coef.dta",replace

**************************************************
***Consumer coef
**************************************************

u "$P/coefs_consumer.dta",clear

keep dm hhno group indvno sugar_prev

gen fcoef = 7
merge m:1 group fcoef using "$P/MonteCarlo/fdraw.dta",keepusing(v$N)
drop if _m==2
drop _m
rename v$N coef_drinks_res
drop fcoef

merge 1:1 dm using "$P/MonteCarlo/pdraw.dta",keepusing(v$N)
drop _m
rename v$N coef_price

merge m:1 dm using "$P/MonteCarlo/xdraw.dta",keepusing(v$N)
drop _m
rename v$N coef_drinks
replace coef_drinks = coef_drinks_res if coef_drinks==.
drop coef_drinks_res

merge m:1 dm using "$P/MonteCarlo/ydraw.dta",keepusing(v$N)
drop _m
rename v$N coef_sugary

sa "$P/MonteCarloResults/$N/coefs_consumer.dta",replace


