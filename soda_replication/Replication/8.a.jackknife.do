clear
cap log close
set more off
set matsize 10000

global OE "$hpc"
global OJ "$hjk"
global X  "$hrs"

u "$OE/Estimation_step1.dta",clear

keep if choice==1

keep csindex hhno indvno group order sugary sugar_prev indrink product sugary brand
gen soda = product<100

bysort hhno indvno: gen N = _N
bysort hhno indvno: gen n = _n

set seed 2340
drawnorm x
sort hhno indvno x
by hhno indvno: gen sample = 1 if _n<=int(N/2)
replace sample = 2 if sample==.
drop x

sa "$OJ/randomsplit.dta",replace

foreach x of numlist 1 2 {
u "$OJ/randomsplit.dta",clear

 keep if sample==`x'

 egen sum=sum(soda),by(hhno indvno)
 gen small`x' = sum<4 
 drop sum

 bysort hhno indvno product: gen f = 1 if _n==1
 egen sum = sum(f),by(hhno indvno)
 gen single`x' = sum==1

 gen drink   = brand<199
 gen outside = brand>=199

 egen sum_drink   = sum(drink),by(hhno indvno)
 egen sum_outside = sum(outside),by(hhno indvno)

 gen indrink`x' = sum_drink>10 & sum_outside>10

 drop drink outside sum_*

 gen temp = sugary 
 egen mean_s = mean(temp),by(hhno indvno)
 gen     sugar_prev`x' = 1 if mean_s==1
 replace sugar_prev`x' = 2 if mean_s==0
 replace sugar_prev`x' = 3 if mean_s!=0&mean_s!=1&mean_s!=. 
 cap lab def fin 1 "All" 2 "None" 3 "Switch"
 lab val sugar_prev fin
 drop temp mean_s

 bysort hhno indvno: keep if _n==1
 
 keep hhno indvno small`x' single`x' sugar_prev`x' indrink`x'
 sa "$OJ/sample`x'.dta",replace
}

u "$OJ/randomsplit.dta",clear

keep if n==1
keep hhno indvno order group sugar_prev indrink N

merge 1:1 hhno indvno using "$OJ/sample1.dta" 
drop _m

merge 1:1 hhno indvno using "$OJ/sample2.dta" 
drop _m

merge m:1 hhno indvno using "$X/coefs_consumer.dta"
drop _m

gen k = 0
replace k = 1 if small1==1|small2==1
replace k = 2 if single1==1|single2==1
replace k = 3 if indrink1!=indrink2
replace k = 4 if sugar_prev1!=sugar_prev2
replace k = 5 if (indrink1==indrink2) & (indrink1!=indrink)
replace k = 6 if (sugar_prev1==sugar_prev2) & (sugar_prev1!=sugar_prev)

tab k
keep if k==0

gen temp = 1-indrink
egen dm2 = group(group order temp hhno indvno)
drop temp

keep hhno indvno dm2
sort hhno indvno

sa "$OJ/sample.dta",replace

u "$OJ/randomsplit.dta",clear

merge m:1 hhno indvno using "$OJ/sample.dta"
keep if _m==3
drop _m

keep csindex hhno indvno sample dm2
sort csindex

sa "$OJ/choice_sample.dta",replace

foreach x of numlist 1(1)3 { 
 foreach y of numlist 1(1)4 {

 u "$OE/Estimation_step1.dta",clear

 merge m:1 csindex using "$OJ/choice_sample.dta"
 keep if _m==3
 drop _m

 drop if sample==`x'
 keep if group==`y'

 clogit choice price drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r* fruit_r* water_r* sugoutside_r* nonoutside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* sugoutside_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q* sugoutside_q*,group(csindex)

 **Price variables
 su dm
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui gen     price_`n' = 0
     qui replace price_`n' = price if dm==`n'
 }

 **Drinks variables
 su dm if order==1 & indrink==1
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui gen     drinks_`n' = 0
     qui replace drinks_`n' = drinks if dm==`n'
 }

 su dm if order==2 & indrink==1
 if r(N)>0 {
  local k = r(min)
  local l = r(max)
  forval n = `k'/`l' {
     qui gen     drinks_`n' = 0
     qui replace drinks_`n' = drinks if dm==`n'
  }
 }

 su dm if order==3 & indrink==1
 if r(N)>0 {
  local k = r(min)
  local l = r(max)
  forval n = `k'/`l' {
     qui gen     drinks_`n' = 0
     qui replace drinks_`n' = drinks if dm==`n'
  }
 }
 gen     drinks_res = 0
 replace drinks_res = drinks if indrink==0 

 **Sugar variables
 su dm if order==1
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui gen     sugary_`n' = 0
     qui replace sugary_`n' = sugary if dm==`n'
 }

 su dm if indrink==1
 local k = r(min)
 local l = r(max)
  
 clogit choice price_* drinks_`k'-drinks_`l' sugary_* inv size288 size330 size380 adstock drinkstmax drinks_res drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r* fruit_r* water_r* sugoutside_r* nonoutside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* sugoutside_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q* sugoutside_q*,group(csindex)

 drop price_* drinks_* sugary_* other_r* fruit_r* water_r* sugoutside_r* nonoutside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* sugoutside_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q* sugoutside_q*

 **Save coefficient estimates
 **Price variables
  su dm
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui replace coef_price = _b[price_`n'] if dm==`n'
     qui replace se_price   = _se[price_`n'] if dm==`n'
 }

 **Drinks variables
 su dm if order==1 & indrink==1
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui replace coef_drinks = _b[drinks_`n'] if dm==`n'
     qui replace se_drinks   = _se[drinks_`n'] if dm==`n'
 }

 su dm if order==2 & indrink==1
 if r(N)>0 {
  local k = r(min)
  local l = r(max)
  forval n = `k'/`l' {
     qui replace coef_drinks = _b[drinks_`n'] if dm==`n'
     qui replace se_drinks   = _se[drinks_`n'] if dm==`n'
  }
 }
 
 su dm if order==3 & indrink==1
 if r(N)>0 {
  local k = r(min)
  local l = r(max)
  forval n = `k'/`l' {
     qui replace coef_drinks = _b[drinks_`n'] if dm==`n'
     qui replace se_drinks   = _se[drinks_`n'] if dm==`n'
  }
 }
 
 qui replace coef_drinks = _b[drinks_res] if indrink==0 
 qui replace se_drinks   = _se[drinks_res] if indrink==0 

 **Sugar variables
 su dm if order==1
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui replace coef_sugary = _b[sugary_`n'] if dm==`n'
     qui replace se_sugary   = _se[sugary_`n'] if dm==`n'
 }
 
 foreach v in inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside {
     qui replace coef_`v' = _b[`v']
     qui replace se_`v'   = _se[`v']
 }

 foreach v in coke cokeoth pepsico gsk barr othsoda othsug water sugoutside {
	forv r = 2010/2014 {
         qui replace coef_`v'_y = _b[`v'_y`r'] if year==`r'
         qui replace se_`v'_y = _se[`v'_y`r']  if year==`r'
	}
	forv q=2/4 {
         qui replace coef_`v'_q = _b[`v'_q`q'] if quarter==`q'
         qui replace se_`v'_q = _se[`v'_q`q']  if quarter==`q'
	}
 }

foreach v in other fruit water sugoutside nonoutside {
	forv n=2/6 {
        qui replace coef_`v'_r  = _b[`v'_r`n']  if rm==`n'
        qui replace se_`v'_r    = _se[`v'_r`n'] if rm==`n'
    }
 }

 sa "$OJ/logit_coefficients_sample`x'_group`y'.dta",replace
 }
}

foreach s of numlist 1(1)3 {
  u "$OJ/logit_coefficients_sample`s'_group1.dta",clear

  append using "$OJ/logit_coefficients_sample`s'_group2.dta"
  append using "$OJ/logit_coefficients_sample`s'_group3.dta"
  append using "$OJ/logit_coefficients_sample`s'_group4.dta"

  bysort hhno indvno: keep if _n==1

  foreach v in price drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside {
	  rename coef_`v' S`s'_coef_`v'
	  rename se_`v'   S`s'_se_`v'
  }

 foreach v in coke cokeoth pepsico gsk barr othsoda othsug water sugoutside {
      rename coef_`v'_y S`s'_coef_`v'_y
      rename se_`v'_y  S`s'_se_`v'_y
      rename coef_`v'_q S`s'_coef_`v'_q
      rename se_`v'_q  S`s'_se_`v'_q
 }

  foreach v in other fruit water sugoutside nonoutside {
     rename coef_`v'_r S`s'_coef_`v'_r
     rename se_`v'_r   S`s'_se_`v'_r
  }

  sa "$OJ/coef_sample_`s'.dta",replace
}

