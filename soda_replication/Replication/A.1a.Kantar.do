clear
cap log close
set more off

global P    "$cd"
global D    "$cd"
global Prog "$pg"


u "$P\transaction_prices.dta",clear
so prodagg rm tm
mer m:1 prodagg rm tm using "$P\prices.dta"

gen dp = price - price_smooth
hist dp
egen p05=pctile(dp), p(05) by(prodagg rm tm)
egen p95=pctile(dp), p(95) by(prodagg rm tm)

drop if abs(dp)>1

sa "$D/price_app1.dta",replace

u "$P/Foodin/all_purchases.dta",clear

keep dmindex
bysort dmindex: gen N = _N
bysort dmindex: keep if _n==1

gen     group = 1 if N<25
replace group = 2 if N>=25 & N<50
replace group = 3 if N>=50 & N<75
replace group = 4 if N>=75 & N<100
replace group = 5 if N>=100 & N<250
replace group = 6 if N>=250

gen i1 = 1

collapse (sum) i,by(group)

egen tot = sum(i)
gen perc1 = (i/tot)*100
drop tot

merge 1:1 group using "$D/T_out.dta"
drop _m

lab def group 1 "$<$25" 2 "25-49" 3 "50-74" 4 "75-99" 5 "100-249" 6 "250+"
lab val group group

format %9.1f perc0 perc1

collapse (sum) i0 perc0 i1 perc1,by(group)

sa "$D/Tdimstats.dta",replace

u "$P/FoodIn/all_purchases.dta",clear

gen i0 = 1

collapse (sum) i0,by(rm)

egen sum = sum(i0)
gen share = 100*(i0/sum)

format %9.1f share

gen store = rm 
lab def storein 1 "Big four" 2 "" 3 "" 4 "" 5 "Discounters" 6 "Other"
lab val store storein

gen store2 = store
lab def storein2 1 "Asda" 2 "Morrisons" 3 "Sainsbury's" 4 "Tesco" 5 "" 6 ""
lab val store2 storein2

bysort store: keep if _n==1

format %9.0fc i0

sa "$D/storestats_in.dta",replace



u "$P0/FoodIn/prices.dta",clear

collapse (mean) price,by(prodagg)

sa "$D/mean_price_in.dta",replace

u "$P0/FoodIn/all_purchases.dta",clear

gen i0 = 1

keep if product<99999

collapse (sum) i0,by(product prodagg brand firm)

egen sum = sum(i0)
gen share = 100*(i0/sum)

merge m:1 prodagg using "$D/mean_price_in.dta"
drop _m

gen o = ""

format %9.2f share price

lab drop product
#delimit ;
lab def product 
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
31 "Other" 
110 "Fruit juice" 120 "Flavoured milk" 130 "Fruit water" 140 "Water"
1011 "Coca Cola multi can" 1012 "Coca Cola Diet multi can" 1013 "Coca Cola bottle"
1014 "Coca Cola Diet bottle" 1015 "Coca Cola multi bottle" 1016 "Coca Cola Diet multi bottle"
1021 "Dr Pepper multi can" 1022 "Dr Pepper Diet multi can" 
1023 "Dr Pepper bottle" 1024 "Dr Pepper Diet bottle"
1023 "Dr Pepper bottle" 1024 "Dr Pepper Diet bottle"
1031 "Fanta multi can" 1032 "Fanta Diet multi can" 
1033 "Fanta bottle" 1034 "Fanta Diet bottle"
1041 "Cherry Coke multi can" 1042 "Cherry Coke Diet multi can" 
1043 "Cherry Coke bottle" 1044 "Cherry Coke Diet bottle"
1061 "Pepsi multi can" 1062 "Pepsi Diet multi can"
1063 "Pepsi bottle" 1064 "Pepsi Diet bottle"
1071 "Lucozade Energy bottle" 1072 "Lucozade Energy multi bottle"
1081 "Ribena multi"
1091 "Sprite multi can" 1092 "Sprite Diet multi can"
1093 "Sprite bottle" 1094 "Sprite Diet bottle"
1101 "Irn Bru multi can" 1102 "Irn Bru Diet multi can"
1103 "Irn Bru bottle" 1104 "Irn Bru Diet bottle"
11001 "Other bg" 11002 "Other Diet bg" 11003 "Other multi" 11004 "Other Diet multi"
11015 "Store" 11016 "Store Diet"
99110 "Fruit juice bg" 99120 "Flavoured milk bg" 99130 "Fruit water bg" 99140 "Water bg";
#delimit cr
lab val product product

sa "$D/productstats_in.dta",replace


**Coefficient table (food in)

insheet using "$O/FoodIn/estimates.raw",clear

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

sa "$P/coefficients_in1.dta",replace

insheet using "$O/FoodIn/estimates.raw",clear

rename v1 coef
rename v2 se
drop v3

keep if _n>15
gen n = _n
gen     group = 1 if n<42
replace group = 2 if n>41&n<83
replace group = 3 if n>82&n<124
replace group = 4 if n>123&n<165
replace group = 5 if n>164

replace n = n-41  if group==2
replace n = n-82  if group==3
replace n = n-123 if group==4
replace n = n-164 if group==5

reshape wide coef se,i(n) j(group)

drop if n>1 & n<12
drop n
gen n = _n

keep if n==1|n==2|n==3|n==4|n==5

reshape long coef se,i(n) j(gp)

gen vr = _n

lab def vf 1 "At-home inventory ($\delta^{\kappa}_{d(i)}$)" 2 "" 3 "" 4 "" 5 "" 6 "Bottle" 7 "" 8 "" 9 "" 10 "" 11 "Multi-pack" 12 "" 13 "" 14 "" 15 "" 16 "Advertising ($\delta^{\mathfrak{a}}_{d(i)}$)" 17 ""  18 "" 19 "" 20 "" 21 "Temperature*Drinks ($\delta^h_{d(i)}$)" 22 "" 23 "" 24 "" 25 ""

lab val vr vf

lab def gp 1 "No kids, high educ." 2 "No kids, low educ." 3 "Pensioners" 4 "Kids, high educ." 5 "Kids, high educ."
lab val gp gp

sa "$P/coefficients_in2.dta",replace

**Outsheet files of MatLab estimates code

u "$O/FoodIn/logit_coefficients_group1_in.dta",clear

append using "$O/FoodIn/logit_coefficients_group2_in.dta"
append using "$O/FoodIn/logit_coefficients_group3_in.dta"
append using "$O/FoodIn/logit_coefficients_group4_in.dta"
append using "$O/FoodIn/logit_coefficients_group5_in.dta"

bysort dm: keep if _n==1
gen dp = 0
gen z_price = coef_price/se_price
replace dp = 1 if z_price>1.96

sort dm

keep dm dp indrink coef_drinks coef_sugar hhtype

sa "$P/FoodIn/dropindex.dta",replace

u "$P/FoodIn/dropindex.dta",clear

sort dm
outsheet dp using "$O/FoodIn/coef_price_index.raw",comma replace non
foreach n of numlist 1(1)5 {
    outsheet dp using "$O/FoodIn/coef_price_index`n'.raw" if hhtype==`n',comma replace non
}

u "$P/FoodIn/dropindex.dta",clear

keep if indrink==1

sort dm
outsheet dp using "$O/FoodIn/coef_soda_index.raw",comma replace non
foreach n of numlist 1(1)5 {
    outsheet dp using "$O/FoodIn/coef_soda_index`n'.raw" if hhtype==`n',comma replace non
}

u "$P/FoodIn/dropindex.dta",clear

keep if coef_sugar!=.

sort dm
outsheet dp using "$O/FoodIn/coef_sugar_index.raw",comma replace non
foreach n of numlist 1(1)5 {
    outsheet dp using "$O/FoodIn/coef_sugar_index`n'.raw" if hhtype==`n',comma replace non
}

u "$P/FoodIn/dropindex.dta",clear

keep if indrink==1 & coef_sugar!=.

sort dm
outsheet dp using "$O/FoodIn/coef_sodasugar_index.raw",comma replace non
foreach n of numlist 1(1)5 {
    outsheet dp using "$O/FoodIn/coef_sodasugar_index`n'.raw" if hhtype==`n',comma replace non
}

