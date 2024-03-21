global O  "$nhp"
global P  "$rs"

**************************************************************************
***Coefficients
**************************************************************************

**Coefficient table 

insheet using "$O/estimates.raw",clear

rename v1 coef
rename v2 se
drop v3

gen var = _n
keep if var<16

gen vr=var

lab def vh 1 "Mean" 2 "Standard deviation" 3 "Skewness" 4 "Kurtosis" 5 "Mean" 6 "Standard deviation" 7 "Skewness" 8 "Kurtosis" 9 "Mean" 10 "Standard deviation" 11 "Skewness" 12 "Kurtosis" 13 "Covariance" 14 "Covariance" 15 "Covariance"
lab val var vh

lab def vr 1 "Price ($\alpha_i$)" 2 "" 3 "" 4 "" 5 "Drinks ($\gamma_i$)" 6 "" 7 "" 8 "" 9 "Sugar ($\beta_i$)" 10 "" 11 "" 12 "" 13 "Price-Drinks" 14 "Price-Sugar" 15 "Drinks-Sugar"
lab val vr vr

order vr var coef se

sa "$P/coefficients1.dta",replace

insheet using "$O/estimates.raw",clear

rename v1 coef
rename v2 se
drop v3

keep if _n>15
gen n = _n
gen     group = 1 if n<23
replace group = 2 if n>22&n<45
replace group = 3 if n>44&n<67
replace group = 4 if n>66

replace n = n-22 if group==2
replace n = n-44 if group==3
replace n = n-66 if group==4

reshape wide coef se,i(n) j(group)

lab val n vf

keep if n==1|n==5|n==6

reshape long coef se,i(n) j(gp)

gen vr = _n

lab def vf 1 "At-home inventory ($\delta^{\kappa}_{d(i)}$)" 2 "" 3 "" 4 "" 5 "Advertising ($\delta^{\mathfrak{a}}_{d(i)}$)" 6 "" 7 "" 8 "" 9 "Temperature*Drinks ($\delta^h_{d(i)}$)" 10 "" 11 "" 12 ""
lab val vr vf

lab def gp 1 "Female,$<$40" 2 "Female,$+$40" 3 "Male,$<$40" 4 "Male,$+$40"
lab val gp gp

sa "$P/coefficients2.dta",replace

