global P  "$rs"
global P2 "$ds"

**************************************************************************
***Counterfactuals - confidence intervals
**************************************************************************

u "$P/MonteCarlo/$N/log_coef.dta",clear

gen UK_tau = $UK_tau

gen soda = product<100

replace size = size/1000

gen     pre_price     = price
gen     post_UK_price = price
replace post_UK_price = price+size*$UK_tau if soda==1 & sugary==1
drop price

gen price=pre_price
predictshr
rename prob pre_prob
rename V Vpre

replace price = post_UK_price
predictshr
rename prob post_UK_prob
rename V Vpost_UK

gen post_UK_CV=(1/coef_price)*((Vpost_UK-Vpre)-(ln(post_UK_prob)-ln(pre_prob)))
drop price

gen diet = 1-sugary
merge m:1 brand diet using "$P2/sugars_prod.dta"
drop if _m==2
drop _m

replace sugars = 5.5   if product==199
replace size   = 0.045 if product==199

keep hhno indvno dm sugar_prev csindex year month week tm rm product size sugars soda sugary pre_prob post_UK_prob pre_price post_UK_price UK_tau post_UK_CV 

sa "$P/MonteCarlo/$N/tax_predictions.dta",replace

u "$P/MonteCarlo/$N/tax_predictions.dta",clear

keep hhno indvno dm csindex year tm rm product size sugars soda sugary pre_prob post_UK_prob pre_price post_UK_price UK_tau  

fillin csindex product

foreach v in soda sugary UK_tau size sugars {
	egen temp = min(`v'),by(product)
	replace `v' = temp if `v'==.
	drop temp
}

foreach v in  dm hhno indvno year tm rm {
	egen temp = min(`v'),by(csindex)
	replace `v' = temp if `v'==.
	drop temp
}

replace pre_prob     = 0 if pre_prob==.
replace post_UK_prob = 0 if post_UK_prob==.

gen     gp = 1 if soda==1 & sugary==1
replace gp = 2 if soda==1 & sugary==0
replace gp = 3 if soda==0 & sugary==1
replace gp = 4 if soda==0 & sugary==0

gen     post_UK_tax = 0
replace post_UK_tax = UK_tau*size if sugary==1&soda==1

collapse (mean) pre_price post_UK_price post_UK_tax pre_prob post_UK_prob,by(product gp)

gen post_UK_dp = post_UK_price-pre_price
gen post_UK_ds = (post_UK_prob-pre_prob)*100

sa "$P/MonteCarlo/$N/product_price.dta",replace


collapse (mean) pre_price post_UK_price post_UK_tax (sum) pre_prob post_UK_prob,by(gp)

gen post_UK_dp = post_UK_price-pre_price
gen post_UK_ds = (post_UK_prob-pre_prob)*100

sa "$P/MonteCarlo/$N/tax_product_predictions.dta",replace

u "$P/MonteCarlo/$N/tax_predictions.dta",clear

keep hhno indvno dm csindex year month week product soda sugary sugars pre_prob post_UK_prob pre_price post_UK_price size UK_tau post_UK_CV sugar_prev

foreach v in pre post_UK {

	gen `v'_soda_vol  = `v'_prob*size if soda==1
	gen `v'_ssoda_vol = `v'_prob*size if soda==1 & sugary==1
	gen `v'_nsoda_vol = `v'_prob*size if soda==1 & sugary==0
	
	gen `v'_salt_vol   = `v'_prob*size if (product==110|product==120|product==130)
	gen `v'_nalt_vol   = `v'_prob*size if product==140
	
	gen `v'_sout_vol  = `v'_prob*size if product==199

	gen `v'_soda_sug = `v'_soda_vol*sugars*10 if soda==1
	gen `v'_alt_sug  = `v'_salt_vol*sugars*10 if (product==110|product==120|product==130)
	gen `v'_out_sug  = `v'_sout_vol*sugars*10 if product==199

	gen     `v'_drk_sug  = `v'_soda_sug 
	replace `v'_drk_sug  = `v'_alt_sug if (product==110|product==120|product==130)

	gen     `v'_tot_sug  = `v'_soda_sug 
	replace `v'_tot_sug  = `v'_alt_sug if (product==110|product==120|product==130)
	replace `v'_tot_sug  = `v'_out_sug if product==199

	gen `v'_sout = `v'_prob if product==199
	gen `v'_nout = `v'_prob if product==999

}

gen     pre_soda_exp = 0
replace pre_soda_exp = pre_price*pre_prob if soda==1

gen     pre_ssoda_exp = 0
replace pre_ssoda_exp = pre_price*pre_prob if sugary==1&soda==1

gen     post_UK_rev = 0
replace post_UK_rev = UK_tau*size*post_UK_prob if sugary==1&soda==1

collapse (sum) *_vol *_sug *_rev *_exp (mean)  *_CV *_sout *_nout,by(year month week csindex dm hhno indvno sugar_prev)

foreach x in pre post_UK {
    foreach v in sout nout {
        replace `x'_`v' = 0 if `x'_`v'==.
    }
    gen `x'_ins = 1-`x'_sout-`x'_nout
}
collapse (sum) *_vol *_sug *_rev *_CV *_exp (mean) *_sout *_nout *_ins,by(dm hhno indvno year sugar_prev)

merge m:1 hhno indvno year using "$P2/active.dta"
keep if _m==3
drop _m

foreach v in _soda_vol _ssoda_vol _nsoda_vol _salt_vol _nalt_vol _sout_vol _soda_sug _alt_sug _out_sug _tot_sug _drk_sug {
    foreach x in pre post_UK {
        replace `x'`v'=`x'`v'*fac*$g
    }
}
foreach v in _rev _CV {
    foreach x in post_UK {
        replace `x'`v'=`x'`v'*fac*$g
    }
}

replace pre_soda_exp  = pre_soda_exp*fac*$g
replace pre_ssoda_exp = pre_ssoda_exp*fac*$g

rename post_UK_CV UK_CV

sa "$P/MonteCarlo/$N/tax_predictions_agg.dta",replace

u "$P2/purchyearfull.dta",clear

keep hhno indvno year age annaddsr annexp_eq agecat asgrp eegrp

merge 1:1 hhno indvno year using "$P/MonteCarlo/$N/tax_predictions_agg.dta"
keep if _m==3
drop _m

sa "$P/MonteCarloResults/$N/tax_predictions_demogs.dta",replace

