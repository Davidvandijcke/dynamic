clear
cap log close
set more off
set matsize 10000

global OJ "$nhp/Jackknife"
global P  "$cd"
global Y  "$ds"

u "$OJ/coef_sample_1.dta",replace

merge 1:1 hhno indvno using "$OJ/coef_sample_2.dta"
drop _m

merge 1:1 hhno indvno using "$OJ/coef_sample_3.dta"
drop _m

sa "$OJ/coefs.dta",replace

u "$OJ/choice_sample.dta",clear

bysort dm2: gen T = _N
bysort dm2: keep if _n==1

sa "$OJ/dm_T.dta",replace

u "$Y/age.dta",clear

collapse (mean) age,by(hhno indvno)

sa "$OJ/age.dta",replace

u "$Y/aggdiet.dta",clear

centile annaddsr,centile(5 95)
gen cl2_annaddsr = r(c_1) 
gen cu2_annaddsr = r(c_2) 

centile annexp_eq,centile(5 95)
gen cl2_annexp_eq = r(c_1) 
gen cu2_annexp_eq = r(c_2) 

collapse (mean) annaddsr annexp_eq cu2_annaddsr cl2_annaddsr cu2_annexp_eq cl2_annexp_eq,by(hhno)

sa "$OJ/dietmeasures.dta",replace

u "$OJ/coefs.dta",clear

keep hhno indvno dm *_price *_drinks *_sugary group

foreach v in price drinks sugary {
	gen correction_`v' = 2*S3_coef_`v'-0.5*(S1_coef_`v'+S2_coef_`v')
	gen diff_`v' = abs(correction_`v'-S3_coef_`v')
	gen diff2_`v' = (correction_`v'-S3_coef_`v')
	gen pdiff_`v'  = (abs(correction_`v'-S3_coef_`v')/abs(S3_coef_`v'))*100
	gen pdiff2_`v' = ((correction_`v'-S3_coef_`v')/abs(S3_coef_`v'))*100
	}

merge m:1 hhno indvno using "$OJ/dm_T.dta" 
drop _m

bysort hhno indvno: gen n = _n
su T if n==1,d
keep if n==1

merge m:1 hhno using "$OJ/dietmeasures.dta"
keep if _m==3 
drop _m

merge m:1 hhno indvno using "$OJ/age.dta"
keep if _m==3
drop _m

sa "$OJ/Jackknife_results.dta",replace
