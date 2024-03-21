
global P  "$rs"
global P2 "$ds"


**************************************************************************
***Counterfactuals
**************************************************************************

u "$P/logit_coefficients.dta",clear

gen US_tau = $US_tau
gen UK_tau = $UK_tau

gen soda = product<100

replace size = size/1000

gen     pre_price     = price
gen     post_US_price = price
replace post_US_price = price+size*$US_tau if soda==1
gen     post_UK_price = price
replace post_UK_price = price+size*$UK_tau if soda==1 & sugary==1
drop price

gen price=pre_price
predictshr
rename prob pre_prob
rename V Vpre

replace price = post_US_price
predictshr
rename prob post_US_prob
rename V Vpost_US

gen post_US_CV=(1/coef_price)*((Vpost_US-Vpre)-(ln(post_US_prob)-ln(pre_prob)))

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

lab var pre_price     "Pre tax price"
lab var Vpre          "Pre tax utility index"
lab var pre_prob      "Pre tax probability"
lab var US_tau        "Soda tax rate"
lab var size          "Product size" 
lab var Vpost_US      "Soda tax utility index"
lab var post_US_prob  "Soda tax probability"
lab var post_US_CV    "Soda tax CV"
lab var post_US_price "Soda tax price"
lab var UK_tau        "Soda tax rate"
lab var Vpost_UK      "Sugary soda tax utility index"
lab var post_UK_prob  "Sugary soda tax probability"
lab var post_UK_CV    "Sugary soda tax CV"
lab var post_UK_price "Sugary soda tax price"

keep hhno indvno dm sugar_prev csindex year month week tm rm product size sugars soda sugary pre_prob post_UK_prob post_US_prob pre_price post_UK_price post_US_price UK_tau US_tau post_US_CV post_UK_CV 
sa "$P/tax_predictions.dta",replace
        
u "$P/tax_predictions.dta",clear

keep hhno indvno dm csindex year tm rm product size sugars soda sugary pre_prob post_UK_prob post_US_prob pre_price post_UK_price post_US_price UK_tau US_tau  

fillin csindex product

foreach v in soda sugary UK_tau US_tau size sugars {
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
replace post_US_prob = 0 if post_US_prob==.

gen     gp = 1 if soda==1 & sugary==1
replace gp = 2 if soda==1 & sugary==0
replace gp = 3 if soda==0 & sugary==1
replace gp = 4 if soda==0 & sugary==0

gen     post_UK_tax = 0
replace post_UK_tax = UK_tau*size if sugary==1&soda==1
gen     post_US_tax = 0
replace post_US_tax = US_tau*size if soda==1

gen     post_UK_rev = 0
replace post_UK_rev = UK_tau*size*post_UK_prob if sugary==1&soda==1

gen     post_US_rev = 0
replace post_US_rev = US_tau*size*post_US_prob if soda==1

drop _f

sa "$P/productlevel.dta",replace

u "$P/productlevel.dta",clear

collapse (mean) pre_price post_UK_price post_UK_tax post_US_price post_US_tax (mean) pre_prob post_UK_prob post_US_prob,by(product year gp)
collapse (mean) pre_price post_UK_price post_UK_tax post_US_price post_US_tax (mean) pre_prob post_UK_prob post_US_prob,by(product gp)

gen post_UK_dp = post_UK_price-pre_price
gen post_UK_ds = (post_UK_prob-pre_prob)*100

gen post_US_dp = post_US_price-pre_price
gen post_US_ds = (post_US_prob-pre_prob)*100

sa "$P/product_price.dta",replace

collapse (sum) pre_prob post_UK_prob post_US_prob (mean) pre_price post_UK_price post_UK_tax  post_US_price post_US_tax,by(gp)

gen post_UK_dp = post_UK_price-pre_price
gen post_UK_ds = (post_UK_prob-pre_prob)*100

gen post_US_dp = post_US_price-pre_price
gen post_US_ds = (post_US_prob-pre_prob)*100

sa "$P/tax_product_predictions.dta",replace

u "$P/tax_predictions.dta",clear

keep hhno indvno dm csindex year month week product soda sugary sugars pre_prob post_US_prob post_UK_prob pre_price post_US_price post_UK_price size US_tau UK_tau post_US_CV post_UK_CV sugar_prev 

foreach v in pre post_US post_UK {

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

gen     post_US_rev = 0
replace post_US_rev = US_tau*size*post_US_prob if soda==1

gen     post_UK_rev = 0
replace post_UK_rev = UK_tau*size*post_UK_prob if sugary==1&soda==1

collapse (sum) *_vol *_sug *_rev *_exp (mean)  *_CV *_sout *_nout,by(year month week csindex dm hhno indvno sugar_prev)

foreach x in pre post_US post_UK {
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
    foreach x in pre post_US post_UK {
        replace `x'`v'=`x'`v'*fac*$g
    }
}
foreach v in _rev _CV {
    foreach x in post_US post_UK {
        replace `x'`v'=`x'`v'*fac*$g
    }
}

replace pre_soda_exp  = pre_soda_exp*fac*$g
replace pre_ssoda_exp = pre_ssoda_exp*fac*$g

rename post_UK_CV UK_CV
rename post_US_CV US_CV

lab var pre_soda_exp         "Exp soda pre tax (pounds)"
lab var pre_ssoda_exp        "Exp sugary soda pre tax (pounds)"

lab var pre_soda_vol         "Vol soda pre tax (l)"
lab var pre_ssoda_vol        "Vol sugary soda pre tax (l)"
lab var pre_nsoda_vol        "Vol diet soda pre tax (l)"
lab var pre_salt_vol         "Vol non soda sugar drink pre tax (l)"
lab var pre_nalt_vol         "Vol water sugar pre tax (l)"
lab var pre_sout_vol         "Vol sugar outside option (g)"

lab var post_US_soda_vol     "Vol soda post soda tax (l)"
lab var post_US_ssoda_vol    "Vol sugary soda post soda tax (l)"
lab var post_US_nsoda_vol    "Vol diet soda post soda tax (l)"
lab var post_US_salt_vol     "Vol non soda sugar drink post soda tax (l)"
lab var post_US_nalt_vol     "Vol water sugar post soda tax (l)"
lab var post_US_sout_vol     "Vol non soda sugar drink post soda tax (g)"

lab var post_UK_soda_vol     "Vol soda post sugary soda tax (l)"
lab var post_UK_ssoda_vol    "Vol sugary soda post sugary soda tax (l)"
lab var post_UK_nsoda_vol    "Vol diet soda post sugary soda tax (l)"
lab var post_UK_salt_vol     "Vol non soda sugar drink post sugary soda tax (l)"
lab var post_UK_nalt_vol     "Vol water sugar post sugary soda tax (l)"
lab var post_UK_sout_vol     "Vol non soda sugar drink post sugary soda tax (g)"

lab var pre_soda_sug         "Sug soda pre tax (g)"
lab var pre_alt_sug          "Sug alt drinks pre tax (g)"
lab var pre_out_sug          "Sug outside option pre tax (g)"
lab var pre_drk_sug          "Sug total drinks pre tax (g)"
lab var pre_tot_sug          "Sug total pre tax (g)"

lab var post_US_soda_sug     "Sug soda post soda tax (g)"
lab var post_US_alt_sug      "Sug alt drinks post soda tax (g)"
lab var post_US_out_sug      "Sug outside option post soda tax (g)"
lab var post_US_drk_sug      "Sug total drinks post soda tax (g)"
lab var post_US_tot_sug      "Sug total post soda tax (g)"

lab var post_UK_soda_sug     "Sug soda post sugary soda tax (g)"
lab var post_UK_alt_sug      "Sug alt drinks post sugary soda tax (g)"
lab var post_UK_out_sug      "Sug outside option post sugary soda tax (g)"
lab var post_UK_drk_sug      "Sug total drinks post sugary soda tax (g)"
lab var post_UK_tot_sug      "Sug total post sugary soda tax (g)"

lab var post_US_rev          "Rev post soda tax (pounds)"
lab var post_UK_rev          "Rev post sugary soda tax (pounds)"

lab var US_CV                "CV post soda tax (pounds)"
lab var UK_CV                "CV post sugary soda tax (pounds)"

lab var pre_sout             "Prob sugary outside option pre tax"
lab var pre_nout             "Prob non sugary outside option pre tax"
lab var pre_ins              "Prob soda pre tax"

lab var post_US_sout         "Prob sugary outside option post soda tax (pounds)"
lab var post_US_nout         "Prob non sugary outside option post soda tax (pounds)"
lab var post_US_ins          "Prob soda post soda tax (pounds)"

lab var post_UK_sout         "Prob sugary outside option post sugary soda tax (pounds)"
lab var post_UK_nout         "Prob non sugary outside option post sugary soda tax (pounds)"
lab var post_UK_ins          "Prob soda post sugary soda tax (pounds)"

sa "$P/tax_predictions_agg.dta",replace


u "$P2/purchyearfull.dta",clear

keep hhno indvno year age annaddsr annexp_eq agecat asgrp eegrp

merge 1:1 hhno indvno year using "$P/tax_predictions_agg.dta"
keep if _m==3
drop _m

sa "$P/tax_predictions_demogs.dta",replace
