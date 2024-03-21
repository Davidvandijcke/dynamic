
clear
cap log close
set more off
set matsize 10000

global P "$hcd"
global O "$hpc"

u "$P/Estimation_data.dta",replace

foreach n of numlist 2(1)6 {
	qui gen other_r`n'       = other==1 & rm==`n'
	qui gen fruit_r`n'       = fruit==1 & rm==`n'
	qui gen water_r`n'       = water==1 & rm==`n'
	qui gen sugoutside_r`n'  = sugoutside==1 & rm==`n'
	qui gen nonoutside_r`n'  = nonoutside==1 & rm==`n'
}
gen drinkstmax = drinks*tmax

gen cokeoth = firm==1 & coke==0
gen pepsico = firm==2
gen gsk     = firm==3
gen barr    = firm==4
gen othsoda = brand==100
gen othsug  = brand==110|brand==120|brand==130

gen     quarter = 1 if month==1|month==2|month==3
replace quarter = 2 if month==4|month==5|month==6
replace quarter = 3 if month==7|month==8|month==9
replace quarter = 4 if month==10|month==11|month==12

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water sugoutside {
	forv y = 2010/2014 {
		gen `v'_y`y' = `v'==1 & year==`y'
	}
	forv q=2/4 {
		gen `v'_q`q' = `v'==1 & quarter==`q'
	}
}

gen temp = 1-indrink
egen dm = group(group order temp hhno indvno)
drop temp

**Initialise coefficients
gen coef_price    = .
gen se_price      = .
gen coef_sugary   = .
gen se_sugary     = .
gen coef_drinks   = .
gen se_drinks     = .

foreach v in inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside {
    gen coef_`v' = .
    gen se_`v'   = .
    gen z_`v'    = .
}

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water sugoutside {
	gen coef_`v'_y = 0
	gen se_`v'_y   = 0

	gen coef_`v'_q = 0
	gen se_`v'_q   = 0
}

foreach v in other fruit water sugoutside nonoutside {
	gen coef_`v'_r = 0
	gen   se_`v'_r = 0
}

drop price
rename price_smooth price

sa "$O/Estimation_step1.dta",replace

foreach g of numlist 1(1)4 {

 log using "$O/estimation_group`g'.log",replace

 u "$O/Estimation_step1.dta",clear
 
 keep if group==`g'
 
 tab order

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

 clogit choice price_* drinks_* sugary_* inv size288 size330 size380 adstock drinkstmax drinks_res drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside other_r* fruit_r* water_r* sugoutside_r* nonoutside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* sugoutside_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q* sugoutside_q*,group(csindex)

 drop price_* drinks_* sugary_* other_r* fruit_r* water_r* sugoutside_r* nonoutside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* sugoutside_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q* sugoutside_q*

 **Outsheet coefficients and covariance matrix

 matrix x1=e(b)
 svmat x1,names(vvector)
 outsheet vvector* if vvector1!=. using "$O/coef`g'.raw", comma nol non replace
 drop vvector*

 matrix x2=e(V)
 svmat x2,names(vvector)
 outsheet vvector* if vvector1!=. using "$O/vcov`g'.raw", comma nol non replace
 drop vvector*

 **Save coefficient estimates
  su dm
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui replace coef_price = _b[price_`n'] if dm==`n'
     qui replace se_price   = _se[price_`n'] if dm==`n'
 }

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
	forv y = 2010/2014 {
         qui replace coef_`v'_y = _b[`v'_y`y'] if year==`y'
         qui replace se_`v'_y = _se[`v'_y`y']  if year==`y'
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

 sa "$O/logit_coefficients_group`g'.dta",replace

 log close
}




