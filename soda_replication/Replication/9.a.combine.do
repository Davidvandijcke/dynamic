global P0 "$cd"
global P2 "$ds"
global P  "$rs"

*******************
***Elasticities
*******************


forval x=1/$BR {
    if `x'==1 u "$P\MonteCarloResults/`x'/elasticities_tableA.dta",clear
    if `x'==1 gen b = 1

    if `x'>1 u "$P\MonteCarloResults/elasticities_tableA_append_ci.dta",clear
    if `x'>1 append using "$P\MonteCarloResults/`x'/elasticities_tableA.dta"

    replace b = `x' if b==.
    disp `x'
    sa "$P\MonteCarloResults/elasticities_tableA_append_ci.dta",replace
}

forval x=1/$BR {
    if `x'==1 u "$P\MonteCarloResults/`x'/elasticities_tableB.dta",clear
    if `x'==1 gen b = 1

    if `x'>1 u "$P\MonteCarloResults/elasticities_tableB_append_ci.dta",clear
    if `x'>1 append using "$P\MonteCarloResults/`x'/elasticities_tableB.dta"

    replace b = `x' if b==.
    disp `x'
    sa "$P\MonteCarloResults/elasticities_tableB_append_ci.dta",replace
}

u "$P\MonteCarloResults/elasticities_tableA_append_ci.dta",clear

append using "$P\MonteCarloResults/elasticities_tableB_append_ci.dta"

rename product v
foreach x in own cross_r cross_d cross_ar cross_ad total {
    egen `x'lb = pctile(`x'),p(2.5) by(v)
    egen `x'ub = pctile(`x'),p(97.5) by(v)
}

bysort v: keep if _n==1
keep v ownlb cross_rlb cross_dlb cross_arlb cross_adlb totallb ownub cross_rub cross_dub cross_arub cross_adub totalub


reshape long own cross_r cross_d cross_ar cross_ad total,i(v) j(stat) string

sa "$P/MonteCarloResults/elasticities_table_ci.dta",replace


u "$P/elasticities_tableA.dta",clear
append using "$P/elasticities_tableB.dta"

gen stat = "mean"
rename product v

append using "$P/MonteCarloResults/elasticities_table_ci.dta"
drop soda sugar

foreach x in own {
    gen `x'_out=round(`x',0.001)
    format `x'_out %4.2f
}
foreach x in cross_r cross_d cross_ar cross_ad total{
    gen `x'_out=round(`x',0.001)
    format `x'_out %4.3f
}


drop own cross_r cross_d cross_ar cross_ad total

encode stat, gen(t1)
drop stat
ren t1 stat

reshape wide own_out cross_r_out cross_d_out cross_ar_out cross_ad_out total_out, i(v) j(stat)

foreach x in own_ cross_r_ cross_d_ cross_ar_ cross_ad_ total_ {
    tostring `x'out1, gen(t1) force usedisplayformat
    tostring `x'out3, gen(t2) force usedisplayformat
    gen     CI`x'="\tiny{["+t1+", "+t2+"]}" if v<1000
    replace CI`x'="\scriptsize{["+t1+", "+t2+"]}" if v>=1000
    drop t1 t2
    }
	
	keep v own_out2 cross_r_out2 cross_d_out2 cross_ar_out2 cross_ad_out2 total_out2 CIown_ CIcross_r_ CIcross_d_ CIcross_ar_ CIcross_ad_ CItotal_
gen o = ""

gen     vr = v
replace vr = 33 if v==110
replace vr = 34 if v==120
replace vr = 35 if v==130
replace vr = 36 if v==140
replace vr = 37 if v==1000
replace vr = 38 if v==2000

#delimit ;
lab def vr
1  "Coca Cola 330" 2  "Coca Cola 500" 3  "Coca Cola Diet 330" 4  "Coca Cola Diet 500" 
5  "Dr Pepper 330" 6  "Dr Pepper 500" 7  "Dr Pepper Diet 500" 
8  "Fanta 330" 9 "Fanta 500" 10 "Fanta Diet 500" 
11  "Cherry Coke 330" 12 "Cherry Coke 500" 13  "Cherry Coke Diet 500" 
14 "Oasis 500" 15 "Oasis Diet 500" 
16 "Pepsi 330" 17 "Pepsi 500" 18  "Pepsi Diet 330" 19 "Pepsi Diet 500" 
20 "Lucozade Energy 380" 21  "Lucozade Energy 500" 
22 "Ribena 288" 23 "Ribena 500" 24 "Ribena Diet 500" 
25 "Sprite 330" 26 "Sprite 500"
27 "Irn Bru 330" 28 "Irn Bru 500" 29 "Irn Bru Diet 330" 30 "Irn Bru Diet 500"
31 "Other" 32 "Other Diet"
33 "Fruit juice" 34 "Flavoured milk" 35 "Fruit water" 36 "Water"
37 "Soft drinks" 38 "Sugary soft drinks";
#delimit cr
lab val vr vr

replace CIcross_d_ = "" if vr==37

sort vr

sa "$P/elasticitiestable.dta",replace 

*******************
***Pass-through desc
*******************

u  "$P0/prices.dta",clear

collapse (mean) size,by(prodagg)

sa "$P/size.dta",replace

u "$P/Passthrough/product_price.dta",clear

drop if product==199|product==999 

merge 1:1 product using "$P0/options_vars.dta",keepusing(prodagg)
drop if _m==2
drop _m

mer m:1 prodagg using "$P/size.dta",keepusing(size)
drop _m

foreach v in  pre_price post_UK_dp post_UK_tax {
	replace `v'=`v'/(size/1000)
}

replace gp = 2 if gp>1

gen i = 1

collapse (sum) i (mean) pre_price post_UK_dp post_UK_tax,by(gp)

xpose,clear

rename v1 all1
rename v2 all0

gen     vr = 1 if _n==2
replace vr = 2 if _n==3
replace vr = 3 if _n==4
replace vr = 4 if _n==5
drop if _n==1
lab def vr 1 "No. products" 2 "Pre-tax price" 3 "Price rise" 4 "Tax"
lab val vr vr

sa "$P/ave_pass.dta",replace


u "$P/Passthrough/product_price.dta",clear

drop if product==199|product==999 

merge 1:1 product using "$P0/options_vars.dta",keepusing(prodagg)
drop if _m==2
drop _m

mer m:1 prodagg using "$P/size.dta",keepusing(size)
drop _m

gen large = size>499

foreach v in  pre_price post_UK_dp post_UK_tax {
	replace `v'=`v'/(size/1000)
}

replace gp = 2 if gp>1

gen i = 1

collapse (sum) i (mean) pre_price post_UK_dp post_UK_tax,by(gp large)

xpose,clear

rename v1 sm1
rename v2 lg1
rename v3 sm0
rename v4 lg0

gen     vr = 1 if _n==3
replace vr = 2 if _n==4
replace vr = 3 if _n==5
replace vr = 4 if _n==6
drop if _n==1|_n==2
cap lab def vr 1 "No. products" 2 "Pre-tax price" 3 "Price rise" 4 "Tax"
lab val vr vr

merge 1:1 vr using "$P/ave_pass.dta"
drop _m

reshape long all sm lg,i(vr) j(gp)

foreach x in all sm lg {
	gen `x'_out=round(`x',0.01)
    format `x'_out %4.2f

	gen `x'_out2=round(`x')
    format `x'_out2 %4.0f
}

sort gp vr

sa "$P/passsum.dta",replace

*******************
***Coefficient results
*******************

forval x=1/$BR {
	u "$P2/hhpurch_base.dta",clear

	merge m:1 hhno indvno using "$P/MonteCarloResults/`x'/coefs_consumer.dta",keepusing(dm coef_price coef_sugary coef_drinks)
	keep if _m==3
	drop _m

	gen i = 1
	
	collapse (sd) coef_price coef_sugary coef_drinks (sum) i,by(agecat)
	
	foreach v in coef_price coef_sugary coef_drinks {
		gen cb_`v' = 1.96*`v'/sqrt(i)
	}
	drop coef_price coef_sugary coef_drinks i
	
    if `x'==1 gen b = 1
    if `x'>1 append using "$P/MonteCarloResults/coef_onthego_age_ci.dta"

    replace b = `x' if b==.
    disp `x'

	sa "$P/MonteCarloResults/coef_onthego_age_ci.dta",replace
}

u "$P/MonteCarloResults/coef_onthego_age_ci.dta",clear

collapse (p95) cb_coef_price cb_coef_sugary cb_coef_drinks,by(agecat)

sa "$P/MonteCarloResults/coef_onthego_age2_ci.dta",replace

u "$P2/hhpurch_base.dta",clear

merge m:1 hhno indvno using "$P/coefs_consumer.dta"
keep if _m==3
drop _m

gen sugpinf=sugar_prev==1
gen sugninf=sugar_prev==2

gen i = 1
	
collapse (mean) coef_price coef_sugary coef_drinks sugpinf sugninf,by(agecat)

merge 1:1 agecat using "$P/MonteCarloResults/coef_onthego_age2_ci.dta"
drop _m

foreach v in coef_price coef_sugary coef_drinks {
	gen lb_`v' = `v'-cb_`v'
	gen ub_`v' = `v'+cb_`v'
}

sa "$P/coefageresults.dta",replace


forval x=1/$BR {
	u "$P2/hhpurch_base.dta",clear

	merge m:1 hhno indvno using "$P/MonteCarloResults/`x'/coefs_consumer.dta",keepusing(dm coef_price coef_sugary coef_drinks)
	keep if _m==3
	drop _m

	gen i = 1
	
	collapse (sd) coef_price coef_sugary coef_drinks (sum) i,by(asgrp)
	
	foreach v in coef_price coef_sugary coef_drinks {
		gen cb_`v' = 1.96*`v'/sqrt(i)
	}
	drop coef_price coef_sugary coef_drinks i
	
    if `x'==1 gen b = 1
    if `x'>1 append using "$P/MonteCarloResults/coef_onthego_adds_ci.dta"

    replace b = `x' if b==.
    disp `x'

	sa "$P/MonteCarloResults/coef_onthego_adds_ci.dta",replace
}

u "$P/MonteCarloResults/coef_onthego_adds_ci.dta",clear

collapse (p95) cb_coef_price cb_coef_sugary cb_coef_drinks,by(asgrp)

sa "$P/MonteCarloResults/coef_onthego_adds2_ci.dta",replace

u "$P2/hhpurch_base.dta",clear

merge m:1 hhno indvno using "$P/coefs_consumer.dta"
keep if _m==3
drop _m

gen sugpinf=sugar_prev==1
gen sugninf=sugar_prev==2

gen i = 1
	
collapse (mean) coef_price coef_sugary coef_drinks sugpinf sugninf,by(asgrp)

merge 1:1 asgrp using "$P/MonteCarloResults/coef_onthego_adds2_ci.dta"
drop _m

foreach v in coef_price coef_sugary coef_drinks {
	gen lb_`v' = `v'-cb_`v'
	gen ub_`v' = `v'+cb_`v'
}

sa "$P/coefaddsugresults.dta",replace


forval x=1/$BR {
	u "$P2/hhpurch_base.dta",clear

	merge m:1 hhno indvno using "$P/MonteCarloResults/`x'/coefs_consumer.dta",keepusing(dm coef_price coef_sugary coef_drinks)
	keep if _m==3
	drop _m

	gen i = 1
	
	collapse (sd) coef_price coef_sugary coef_drinks (sum) i,by(eegrp)
	
	foreach v in coef_price coef_sugary coef_drinks {
		gen cb_`v' = 1.96*`v'/sqrt(i)
	}
	drop coef_price coef_sugary coef_drinks i
	
    if `x'==1 gen b = 1
    if `x'>1 append using "$P/MonteCarloResults/coef_onthego_eexp_ci.dta"

    replace b = `x' if b==.
    disp `x'

	sa "$P/MonteCarloResults/coef_onthego_eexp_ci.dta",replace
}

u "$P/MonteCarloResults/coef_onthego_eexp_ci.dta",clear

collapse (p95) cb_coef_price cb_coef_sugary cb_coef_drinks,by(eegrp)

sa "$P/MonteCarloResults/coef_onthego_eexp2_ci.dta",replace

u "$P2/hhpurch_base.dta",clear

merge m:1 hhno indvno using "$P/coefs_consumer.dta"
keep if _m==3
drop _m

gen sugpinf=sugar_prev==1
gen sugninf=sugar_prev==2

gen i = 1
	
collapse (mean) coef_price coef_sugary coef_drinks sugpinf sugninf,by(eegrp)

merge 1:1 eegrp using "$P/MonteCarloResults/coef_onthego_eexp2_ci.dta"
drop _m

foreach v in coef_price coef_sugary coef_drinks {
	gen lb_`v' = `v'-cb_`v'
	gen ub_`v' = `v'+cb_`v'
}

sa "$P/coefexpresults.dta",replace

*******************
***Counterfactual results
*******************


forval x=1/$BR {

	u "$P/MonteCarloResults/`x'/tax_predictions_demogs.dta",clear

	gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
	gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
	gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)
	
	collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(year agecat)
	
	gen i = 1
	
	collapse (sd) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV (sum) i,by(agecat)

	foreach v in diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV {
		gen cb_`v' = 1.96*`v'/sqrt(i)
	}
	
	drop diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV i

    if `x'==1 gen b = 1
    if `x'>1 append using "$P\MonteCarloResults/tax_predictions_age_ci.dta"

    replace b = `x' if b==.
    disp `x'

	sa "$P\MonteCarloResults/tax_predictions_age_ci.dta",replace
}

u "$P\MonteCarloResults/tax_predictions_age_ci.dta",clear

collapse (p95) cb_diff_UK_tot_sug cb_diff_UK_drk_sug cb_diff_UK_soda_sug cb_UK_CV,by(agecat)

sa "$P/MonteCarloResults/tax_predictions_age2_ci.dta",replace

u "$P/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(year agecat)
collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(agecat)

merge 1:1 agecat using "$P/MonteCarloResults/tax_predictions_age2_ci.dta"
drop _m

foreach v in  diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV {
	gen lb_`v' = `v'-cb_`v'
	gen ub_`v' = `v'+cb_`v'
}

sa "$P/taxageresults.dta",replace

forval x=1/$BR {

	u "$P/MonteCarloResults/`x'/tax_predictions_demogs.dta",clear

	gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
	gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
	gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)
	
	collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(year asgrp)
	
	gen i = 1
	
	collapse (sd) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV (sum) i,by(asgrp)

	foreach v in diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV {
		gen cb_`v' = 1.96*`v'/sqrt(i)
	}
	
	drop diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV i

    if `x'==1 gen b = 1
    if `x'>1 append using "$P\MonteCarloResults/tax_predictions_adds_ci.dta"

    replace b = `x' if b==.
    disp `x'

	sa "$P\MonteCarloResults/tax_predictions_adds_ci.dta",replace
}

u "$P\MonteCarloResults/tax_predictions_adds_ci.dta",clear

collapse (p95) cb_diff_UK_tot_sug cb_diff_UK_drk_sug cb_diff_UK_soda_sug cb_UK_CV,by(asgrp)

sa "$P/MonteCarloResults/tax_predictions_adds2_ci.dta",replace

u "$P/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(year asgrp)
collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(asgrp)

merge 1:1 asgrp using "$P/MonteCarloResults/tax_predictions_adds2_ci.dta"
drop _m

foreach v in  diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV {
	gen lb_`v' = `v'-cb_`v'
	gen ub_`v' = `v'+cb_`v'
}

sa "$P/taxaddsugresults.dta",replace



forval x=1/$BR {

	u "$P/MonteCarloResults/`x'/tax_predictions_demogs.dta",clear

	gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
	gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
	gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)
	
	collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(dm year eegrp)
	
	gen i = 1
	
	collapse (sd) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV (sum) i,by(eegrp)

	foreach v in diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV {
		gen cb_`v' = 1.96*`v'/sqrt(i)
	}
	
	drop diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV i

    if `x'==1 gen b = 1
    if `x'>1 append using "$P\MonteCarloResults/tax_predictions_eexp_ci.dta"

    replace b = `x' if b==.
    disp `x'

	sa "$P\MonteCarloResults/tax_predictions_eexp_ci.dta",replace
}

u "$P\MonteCarloResults/tax_predictions_eexp_ci.dta",clear

collapse (p95) cb_diff_UK_tot_sug cb_diff_UK_drk_sug cb_diff_UK_soda_sug cb_UK_CV,by(eegrp)

sa "$P/MonteCarloResults/tax_predictions_eexp2_ci.dta",replace

u "$P/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(year eegrp)
collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV,by(eegrp)

merge 1:1 eegrp using "$P/MonteCarloResults/tax_predictions_eexp2_ci.dta"
drop _m

foreach v in  diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug UK_CV {
	gen lb_`v' = `v'-cb_`v'
	gen ub_`v' = `v'+cb_`v'
}

sa "$P/taxexpresults.dta",replace


********************************************************************************
***Outsheet data for Figure 5 and Figure 6 panels (d)-(f)
********************************************************************************

u "$P2/purchyearfull.dta",clear

collapse (mean) sodapurch,by(asgrp agecat)

outsheet asgrp agecat sodapurch using "$P/sodap_agesug.raw",comma nol non replace


u "$P/tax_predictions_demogs.dta",clear

gen UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen US_tot_sug = -(post_US_tot_sug-pre_tot_sug)

collapse (mean) UK_tot_sug UK_CV US_tot_sug,by(asgrp agecat year)

collapse (mean) UK_tot_sug UK_CV US_tot_sug,by(asgrp agecat)

outsheet asgrp agecat UK_tot_sug UK_CV US_tot_sug using "$P/agesug.raw",comma nol non replace


u "$P/tax_predictions_demogs.dta",clear

gen UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen US_tot_sug = -(post_US_tot_sug-pre_tot_sug)

collapse (mean) UK_tot_sug UK_CV US_tot_sug,by(eegrp agecat year)

collapse (mean) UK_tot_sug UK_CV US_tot_sug,by(eegrp agecat)

outsheet eegrp agecat UK_tot_sug UK_CV US_tot_sug using "$P/ageexp.raw",comma nol non replace


u "$P/tax_predictions_demogs.dta",clear

gen UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen US_tot_sug = -(post_US_tot_sug-pre_tot_sug)

collapse (mean) UK_tot_sug UK_CV US_tot_sug,by(asgrp eegrp year)

collapse (mean) UK_tot_sug UK_CV US_tot_sug,by(asgrp eegrp)

outsheet asgrp eegrp UK_tot_sug UK_CV US_tot_sug using "$P/sugexp.raw",comma nol non replace



u "$P/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug,by(agecat year)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug,by(agecat)

sa "$P/predictions_fullpassthrough_age.dta",replace

u "$P/Passthrough/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug_eq = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug_eq = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug_eq = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug_eq diff_UK_drk_sug_eq diff_UK_soda_sug_eq,by(agecat year)

collapse (mean) diff_UK_tot_sug_eq diff_UK_drk_sug_eq diff_UK_soda_sug_eq,by(agecat)

merge 1:1 agecat using "$P/predictions_fullpassthrough_age.dta"
drop _m

sa "$P/passageresults.dta",replace


*******************
***Counterfactual results (with eq.  passthrough)
*******************

u "$P/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug,by(asgrp year)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug,by(asgrp)

sa "$P/predictions_fullpassthrough_asgrp.dta",replace

u "$P/Passthrough/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug_eq = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug_eq = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug_eq = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug_eq diff_UK_drk_sug_eq diff_UK_soda_sug_eq,by(asgrp year)

collapse (mean) diff_UK_tot_sug_eq diff_UK_drk_sug_eq diff_UK_soda_sug_eq,by(asgrp)

merge 1:1 asgrp using "$P/predictions_fullpassthrough_asgrp.dta"
drop _m

sa "$P/passaddsugresults.dta",replace


u "$P/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug,by(eegrp year)

collapse (mean) diff_UK_tot_sug diff_UK_drk_sug diff_UK_soda_sug,by(eegrp)

sa "$P/predictions_fullpassthrough_eegrp.dta",replace

u "$P/Passthrough/tax_predictions_demogs.dta",clear

gen diff_UK_tot_sug_eq = -(post_UK_tot_sug-pre_tot_sug)
gen diff_UK_drk_sug_eq = -(post_UK_drk_sug-pre_drk_sug)
gen diff_UK_soda_sug_eq = -(post_UK_soda_sug-pre_soda_sug)

collapse (mean) diff_UK_tot_sug_eq diff_UK_drk_sug_eq diff_UK_soda_sug_eq,by(eegrp year)

collapse (mean) diff_UK_tot_sug_eq diff_UK_drk_sug_eq diff_UK_soda_sug_eq,by(eegrp)

merge 1:1 eegrp using "$P/predictions_fullpassthrough_eegrp.dta"
drop _m

sa "$P/passexpresults.dta",replace
