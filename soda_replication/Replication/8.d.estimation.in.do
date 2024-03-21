
clear
cap log close
set more off
set matsize 10000

global P "$hcd/FoodIn"
global O "$hpc/FoodIn"

u "$P/Estimation_data_cs.dta",replace

foreach n of numlist 2(1)6 { // bunch of the variables like store_r get generated here
	foreach v in other store fruit water outside {
		qui gen `v'_r`n' = `v'==1 & rm==`n' // rm is store type
	}
}
drop store_r6
gen drinkstmax = drinks*tmax

foreach v in coke drpepper fanta cherry pepsi lucenergy ribena sprite irnbru other water {
	gen `v'_sm = `v' & product>1000
}

gen cokeoth = firm==1 & coke==0
gen pepsico = firm==2
gen gsk     = firm==3
gen barr    = firm==4
gen othsoda = brand==100|brand==101
gen othsug  = brand==110|brand==120|brand==130

gen     quarter = 1 if month==1|month==2|month==3
replace quarter = 2 if month==4|month==5|month==6
replace quarter = 3 if month==7|month==8|month==9
replace quarter = 4 if month==10|month==11|month==12

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water {
	forv y = 2010/2014 {
		gen `v'_y`y' = `v'==1 & year==`y'
	}
	forv q=2/4 {
		gen `v'_q`q' = `v'==1 & quarter==`q'
	}
}

gen temp = 1-indrink
egen dm = group(hhtype order temp hhno)
drop temp

**Initialise coefficients
gen coef_price  = .
gen se_price    = .
gen coef_sugary = .
gen se_sugary   = .
gen coef_drinks = .
gen se_drinks   = .

foreach v in inv size288 size330 size380 size500 size3 size4 size5 size6 size7 size8 bottle multi adstock drinksmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater water coke_sm drpepper_sm fanta_sm cherry_sm pepsi_sm lucenergy_sm ribena_sm sprite_sm irnbru_sm other_sm water_sm {
    gen coef_`v' = .
    gen se_`v'   = .
}

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water {
	gen coef_`v'_y = 0
	gen se_`v'_y   = 0

	gen coef_`v'_q = 0
	gen se_`v'_q   = 0
}

foreach v in other store fruit water outside {
	gen coef_`v'_r = 0
	gen   se_`v'_r = 0
}

sa "$O/Estimation_step1_in.dta",replace

foreach g of numlist 1(1)1 {

 log using "$O/estimation_group`g'_in.log",replace

 u "$O/Estimation_step1_in.dta",clear
 
 keep if hhtype==`g'

 clogit choice price drinks sugary inv size288 size330 size380 size500 size3-size8 bottle multi adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater water coke_sm drpepper_sm fanta_sm cherry_sm pepsi_sm lucenergy_sm ribena_sm sprite_sm irnbru_sm other_sm water_sm other_r* store_r* fruit_r* water_r* outside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q*,group(csindex) // r is type, q is quarter fixed effects
 
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
 
 clogit choice price_* drinks_* sugary_* inv size288 size330 size380 size500 size3-size8 bottle multi adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater water coke_sm drpepper_sm fanta_sm cherry_sm pepsi_sm lucenergy_sm ribena_sm sprite_sm irnbru_sm other_sm water_sm other_r* store_r* fruit_r* water_r* outside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q*,group(csindex) // egen csindex = group(hhno indvno date)


 drop price_* drinks_* sugary_* other_r* store_r* fruit_r* water_r* outside_r* coke_y* cokeoth_y* pepsico_y* gsk_y* barr_y* othsoda_y* othsug_y* water_y* coke_q* cokeoth_q* pepsico_q* gsk_q* barr_q* othsoda_q* othsug_q* water_q*

 **Outsheet coefficients and covariance matrix

 matrix x1=e(b)
 svmat x1,names(vvector)
 outsheet vvector* if vvector1!=. using "$O/coef`g'_in.raw", comma nol non replace
 drop vvector*

 matrix x2=e(V)
 svmat x2,names(vvector)
 outsheet vvector* if vvector1!=. using "$O/vcov`g'_in.raw", comma nol non replace
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

 rename coef_drinksmax coef_drinkstmax
 rename se_drinksmax se_drinkstmax

 su dm if order==1
 local k = r(min)
 local l = r(max)
 forval n = `k'/`l' {
     qui replace coef_sugary = _b[sugary_`n'] if dm==`n'
     qui replace se_sugary   = _se[sugary_`n'] if dm==`n'
 }

 foreach v in inv size288 size330 size380 size500 size3 size4 size5 size6 size7 size8 bottle multi adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater water coke_sm drpepper_sm fanta_sm cherry_sm pepsi_sm lucenergy_sm ribena_sm sprite_sm irnbru_sm other_sm water_sm {
     qui replace coef_`v' = _b[`v']
     qui replace se_`v'   = _se[`v']
 }

foreach v in coke cokeoth pepsico gsk barr othsoda othsug water {
	forv y = 2010/2014 {
         qui replace coef_`v'_y = _b[`v'_y`y'] if year==`y'
         qui replace se_`v'_y = _se[`v'_y`y']  if year==`y'
	}
	forv q=2/4 {
         qui replace coef_`v'_q = _b[`v'_q`q'] if quarter==`q'
         qui replace se_`v'_q = _se[`v'_q`q']  if quarter==`q'
	}
 }

 foreach v in other store fruit water outside {
	forv n=2/5 {
        qui replace coef_`v'_r  = _b[`v'_r`n']  if rm==`n'
        qui replace se_`v'_r    = _se[`v'_r`n'] if rm==`n'
    }
 }
 foreach v in other fruit water outside {
    qui replace coef_`v'_r  = _b[`v'_r6]  if rm==6
    qui replace se_`v'_r    = _se[`v'_r6] if rm==6
 }
 
 
 sa "$O/logit_coefficients_group`g'_in.dta",replace

 log close
}
