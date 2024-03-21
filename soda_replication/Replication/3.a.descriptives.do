clear
cap log close
set more off

global P0 "$cd"
global D  "$ds"

**************************************************
**Sugar contents
**************************************************

u "M:/TNS/extractedfiles/nutrient_data/RF84.dta",clear

foreach n of numlist 84 647 648 656 657 658 659 1179 1342 1343 {
	append using "M:/TNS/extractedfiles/nutrient_data/RF`n'.dta"
}
drop if date<20090601
drop if date>20141228

merge m:1 prodcode using "$P0/attributes.dta",keepusing(brand diet)
keep if _m==3
drop _m

collapse (mean) sugars,by(brand diet)

replace sugar = 0 if brand==140

sa "$D/sugars_prod.dta",replace

**************************************************
**Active weeks per hhno-indvno-year
**************************************************

u "$P0/FOTGpurchases.dta",clear

merge m:1 hhno indvno using "$P0/indvno_panelstats.dta"
keep if _m==3
drop _m

bysort hhno indvno week: keep if _n==1
gen i = 1

collapse (sum) i,by(hhno indvno year)

gen fac = 52/i

keep hhno indvno year fac

sa "$D/active.dta",replace

**************************************************
**Equivalised expenditure and share of calories from sugar
**************************************************

u "M:/TNS/extractedfiles/panel_data/hhpanel_all.dta",clear

drop if demyear<2009
rename demyear year

rename msage age
rename mssex sex

foreach x of numlist 1(1)12 {
    sort hhno year
    by hhno: replace ageper`x' = ageper`x'[_n-1]+1 if ageper`x'==.
    by hhno: replace ageper`x' = ageper`x'[_n+1]-1 if ageper`x'==.&ageper`x'[_n+1]>1
}

foreach x in hhinc bmi_group hhsize class msempstat hohempstat {
    sort hhno year
    by hhno: replace `x' = `x'[_n-1] if `x'==.
    by hhno: replace `x' = `x'[_n+1] if `x'==.
}

gen nkids0_13=0
gen nkids14_18=0
gen nad=0
foreach n of numlist 1(1)12 {
   replace nkids0_13=nkids0_13+1 if ageper`n'<=13
   replace nkids14_18=nkids14_18+1 if ageper`n'>=14&ageper`n'<=18
   replace nad=nad+1 if ageper`n'>18&ageper`n'<.
}

gen numeqads=(0.67+(nad-1)*0.33)/0.67
gen numeqkids=(0.2*nkids0_13+0.33*nkids14_18)/0.67
gen hheqsize = numeqads+numeqkids

keep hhno year hhinc bmi_group hhsize class msempstat hohempstat hheqsize 

foreach x in hhinc bmi_group hhsize class msempstat hohempstat hheqsize {
    sort hhno year
    by hhno: replace `x' = `x'[_n-1] if `x'==.
    by hhno: replace `x' = `x'[_n+1] if `x'==.
}


gen     labour = 1 if msempstat==1 & hohempstat==1 & hhsize>1
replace labour = 1 if msempstat==1 & hhsize==1
replace labour = 2 if msempstat==1 & hohempstat>1 & hhsize>1
replace labour = 2 if msempstat>1 & hohempstat==1 & hhsize>1
replace labour = 3 if msempstat!=1 & msempstat!=6 & hohempstat!=1 & hhsize>1
replace labour = 3 if msempstat!=1 & hohempstat!=1 & hohempstat!=6 & hhsize>1
replace labour = 3 if msempstat!=1 & msempstat!=6 & hhsize==1
replace labour = 4 if msempstat==6 & hohempstat==6 & hhsize>1
replace labour = 4 if msempstat==6 & hhsize==1

lab def labour 1 "Full time working household" 2 "One member full work" 3 "Non full time working household" 4 "Retired household"
lab val labour labour

gen     income = 0 if hhinc==0
replace income = 1 if hhinc==1|hhinc==2
replace income = 2 if hhinc==3|hhinc==4
replace income = 3 if hhinc>4

lab def income 0 "Unknown" 1 "<£20k" 2 "£20k-£40k" 3 "£40k+"
lab val income income

gen     temp = 5000  if hhinc==1
replace temp = 15000 if hhinc==2
replace temp = 25000 if hhinc==3
replace temp = 35000 if hhinc==4
replace temp = 45000 if hhinc==5
replace temp = 55000 if hhinc==6
replace temp = 65000 if hhinc==7
replace temp = 75000 if hhinc==8

gen temp_eq = temp/hheqsize
centile temp_eq,centile(25 50 75)
gen     income_eq = 1 if              temp_eq<r(c_1)
replace income_eq = 2 if temp_eq>=r(c_1)&temp_eq<r(c_2)
replace income_eq = 3 if temp_eq>=r(c_2)&temp_eq<r(c_3)
replace income_eq = 4 if temp_eq>=r(c_3)&temp_eq<.
replace income_eq = 0 if hhincome==0
drop temp_eq

lab def income_eq 0 "Unknown" 1 "1st q" 2 "2nd q" 3 "3rd q" 4 "4th q"
lab val income_eq income_eq

gen     hhmember = hhsize
replace hhmember = 5 if hhsize>5

keep hhno year income income_eq hhinc bmi_group hhsize class labour hheqsize 

sa "$D/demogs.dta",replace

u "M:/TNS/extractedfiles/index_files/Household_sample_16.dta",clear

merge m:1 date using "$P0/week.dta"
keep if _m==3
drop _m

bysort hhno year week: keep if _n==1
gen obs = 1
collapse (sum) obs,by(hhno year)

sa "$D/weekindata.dta",replace

foreach y of numlist 2009(1)2014 {
	u "M:/TNS/extractedfiles/usda_data/USDA_purchases`y'_hhyrmonth.dta",clear

	if `y'>2009 append using "$D/aggdiet_a.dta"

    collapse (sum) vol_cals vol_protein vol_carbs vol_fat vol_sugars vol_added vol_fibre vol_sodium vol_saturates expenditure,by(hhno year)

    sa "$D/aggdiet_a.dta",replace
}

u "$D/aggdiet_a.dta",clear

merge m:1 hhno year using "$D/weekindata.dta"
keep if _m==3
drop _m

merge m:1 hhno year using "$D/demogs.dta"

sort hhno year
foreach v in bmi_group class hhsize hheqsize labour income income_eq {
  forv x = 1/4 {
	by hhno: replace `v' = `v'[_n+`x'] if `v'==.
	by hhno: replace `v' = `v'[_n-`x'] if `v'==.
  }
}
drop if _m==2
drop _m

***Equivalised expenditure
gen     annexp_eq = exp*(52/obs)/(hheqsize*1000) 
***Equivalised total sugar
gen     annadd_eq = vol_added*(52/obs)/(hheqsize*1000) 
***Added sugar calorie share
gen annaddsr = ((vol_added*4)/(vol_carbs*4+vol_protein*4+vol_fat*9))*100

drop obs hhincome

lab var hhno             "Household Number"  
lab var year             "Year"              
lab var vol_cals         "Calories"          
lab var vol_protein      "Protein"           
lab var vol_carbs        "Carbs"             
lab var vol_fat          "Fat"               
lab var vol_sugars       "Sugars"            
lab var vol_addedsugars  "Added Sugars"      
lab var vol_fibre        "Fibre"             
lab var vol_sodium       "Sodium"            
lab var vol_saturates    "Saturates"         
lab var expenditure      "Expenditure"       
lab var bmi_group        "Bmi"               
lab var class            "Class"             
lab var hhsize           "Size"              
lab var hheqsize         "Equivalent size"   
lab var labour           "Labour market"     
lab var income           "Income"            
lab var income_eq        "Equivalised income"
lab var annexp_eq        "Equivalised expenditure"               
lab var annadd_eq        "Equivalised added sugar"               
lab var annaddsr         "Share of cal from added sugar"               

sa "$D/aggdiet.dta",replace

*************************************************************************************************
**Define deciles
*************************************************************************************************

u "$P0/FOTGpurchases.dta",clear

keep hhno indvno year
bysort hhno indvno year: keep if _n==1

merge m:1 hhno year using "$D/aggdiet.dta",keepusing(annexp_eq annaddsr)
sort hhno indvno year
by hhno indvno: replace annexp_eq=annexp_eq[_n+1] if annexp_eq==.
by hhno indvno: replace annaddsr=annaddsr[_n+1] if annaddsr==.
drop if _m==2
drop _m

foreach n of numlist 10 20 30 40 50 60 70 80 90 {
	egen exp`n' = pctile(annexp_eq),p(`n')
	egen sug`n' = pctile(annaddsr),p(`n')
}

gen i = 1
keep if _n==1
keep i exp10-sug90

sa "$D/centiles.dta",replace

*************************************************************************************************
**Purchases of soda, drinks and other for whole sample
*************************************************************************************************

u "M:/TNS/extractedfiles/fotg_data/panel_all.dta",clear

rename demyear year 
keep hhno indvno year age

bysort hhno indvno year: keep if _n==1

sa "$D/age.dta",replace

u "$P0/prices.dta",clear

bysort prodagg: keep if _n==1
keep prodagg size

sa "$D/size.dta",replace


u "M:/TNS/extractedfiles/fotg_data/purchase_all.dta",clear

drop if year==2015
drop if year==2014 & month==12 & dayofmonth>28

format date %td
keep  hhno indvno date month year week demyear prodcode npacks expenditure volume shopcode
order hhno indvno date month year week demyear prodcode npacks expenditure volume shopcode
drop if exp==0|vol==0
drop if npacks>3

gen day=day(date)
drop date
gen long date=year*10000+month*100+day
drop day

merge m:1 prodcode using "$P0/attributes.dta"
drop if _m==2
drop _m

merge m:1 brand diet using "$D/sugars_prod.dta"
drop if _m==2
drop _m
rename brand brand_new
rename diet  diet_new

merge m:1 prodagg using "$D/size.dta"
drop _m

merge m:1 prodcode using "M:/TNS/extractedfiles/fotg_data/rf1545_16.dta",keepusing(totalfotgsector brand)
keep if _m==3
drop _m

replace volume = (size*npacks)/1000
gen  volsugars = 10*sugars*volume

gen diet = index(brand,"Diet")>0|index(brand,"Zero")>0|index(brand,"Light")>0|index(brand,"Mx")>0|index(brand,"Max")>0|index(brand,"Lite")>0|index(brand,"Free")>0|index(brand,"Lght")>0|index(brand,"Dt")>0|index(brand,"NAS")>0|index(brand,"Beach")
gen addition = product==. & diet==0 & (totalfotgsector=="Bottled Colas"|totalfotgsector=="Bottled Flavours"|totalfotgsector=="Canned Colas"|totalfotgsector=="Canned Flavours"|totalfotgsector=="Fruit Juice/Drink")
gen temp = volsugars if diet_new==0 & product<100
egen temp2 = mean(temp)
replace volsugars = temp2 if addition==1
drop temp temp2

merge m:1 hhno indvno using "$P0/indvno_sample.dta"
replace indemand=0 if _m!=3
drop _m entry exit

gen     soda = brand_new<110|addition==1
replace soda = 2 if brand_new==110|brand_new==120|brand_new==130

lab def soda 0 "Other" 1 "Soda" 2 "Non soda drinks" 
lab val soda soda

gen bot = size==500
gen tax = sugars>1

replace bot = . if product==.

collapse (sum) volume volsugars (mean) bot tax indemand,by(hhno indvno year month date soda)

gen N = soda==1

egen sodapurch = max(indemand),by(hhno indvno)

collapse (sum) volume volsugars N (max) sodapurch (mean) bot tax,by(hhno indvno year soda)

egen totsugars = sum(volsugars),by(hhno indvno year)
egen totvolume = sum(volume),by(hhno indvno year)

rename volsugars sugars

foreach v in sugars volume N bot tax {
	gen  temp = `v' if soda==1
	egen soda`v' = min(temp),by(hhno indvno year)
	replace soda`v' = 0 if soda`v'==.
	drop `v' temp
}

bysort hhno indvno year: keep if _n==1
drop soda

merge m:1 hhno indvno year using "$D/active.dta"
keep if _m==3
drop _m

foreach v in totsugars totvolume sodasugars sodavolume sodaN {
	replace `v' = `v'*fac
}

merge m:1 hhno year using "$D/aggdiet.dta",keepusing(annexp_eq annaddsr hheqsize hhsize class)
drop if _m==2
egen temp = mean(annexp_eq),by(hhno)
replace annexp_eq = temp if annexp_eq==.
drop temp
egen temp = mean(annaddsr),by(hhno)
replace annaddsr = temp if annaddsr==.
drop temp
egen temp = mean(hheqsize),by(hhno)
replace hheqsize = temp if hheqsize==.
drop temp
egen temp = mean(hhsize),by(hhno)
replace hhsize = temp if hhsize==.
drop temp _m
egen temp = mean(class),by(hhno)
replace class = temp if class==.
drop temp
gen temp = round(class,1)
replace class = temp
drop temp

merge m:1 hhno indvno year using "$D/age.dta"
sort hhno indvno year
forv x=1/4 {
	by hhno indvno: replace age = age[_n-`x']+`x' if age==.
	by hhno indvno: replace age = age[_n+`x']-`x' if age==.
}
drop if _m==2
drop _m

gen i = 1
merge m:1 i using "$D/centiles.dta"
drop _m

gen     agecat = 1 if age<=21
replace agecat = 2 if age>21&age<=30
replace agecat = 3 if age>30&age<=40
replace agecat = 4 if age>40&age<=50
replace agecat = 5 if age>50&age<=60
replace agecat = 6 if age>60

lab def agecat  0 "<13" 1 "13-21" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 ">60"
lab val agecat agecat

gen     eegrp = 1  if annexp_eq<exp10
replace eegrp = 2  if annexp_eq<exp20&annexp_eq>=exp10
replace eegrp = 3  if annexp_eq<exp30&annexp_eq>=exp20
replace eegrp = 4  if annexp_eq<exp40&annexp_eq>=exp30
replace eegrp = 5  if annexp_eq<exp50&annexp_eq>=exp40
replace eegrp = 6  if annexp_eq<exp60&annexp_eq>=exp50
replace eegrp = 7  if annexp_eq<exp70&annexp_eq>=exp60
replace eegrp = 8  if annexp_eq<exp80&annexp_eq>=exp70
replace eegrp = 9  if annexp_eq<exp90&annexp_eq>=exp80
replace eegrp = 10 if annexp_eq>=exp90  

gen     asgrp = 1  if annaddsr<sug10
replace asgrp = 2  if annaddsr<sug20&annaddsr>=sug10
replace asgrp = 3  if annaddsr<sug30&annaddsr>=sug20
replace asgrp = 4  if annaddsr<sug40&annaddsr>=sug30
replace asgrp = 5  if annaddsr<sug50&annaddsr>=sug40
replace asgrp = 6  if annaddsr<sug60&annaddsr>=sug50
replace asgrp = 7  if annaddsr<sug70&annaddsr>=sug60
replace asgrp = 8  if annaddsr<sug80&annaddsr>=sug70
replace asgrp = 9  if annaddsr<sug90&annaddsr>=sug80
replace asgrp = 10 if annaddsr>=sug90

keep  hhno indvno year age hheqsize hhsize class annaddsr annexp_eq agecat asgrp eegrp sodapurch totsugars totvolume sodasugars sodavolume sodaN sodabot sodatax 
order hhno indvno year age hheqsize hhsize class annaddsr annexp_eq agecat asgrp eegrp sodapurch totsugars totvolume sodasugars sodavolume sodaN sodabot sodatax 

lab var asgrp      "Added sugar deciles"
lab var eegrp      "Grocery exp deciles"
lab var sodapurch  "=1 for estimation"
lab var totsugars  "Sugars for drinks"
lab var totvolume  "Volume of drinks"
lab var sodasugars "Sugars for soda"
lab var sodavolume "Volume of soda"
lab var sodaN	   "Number of soda purch"
lab var sodabot    "Fraction of soda in 500ml"
lab var sodatax    "Fraction of soda sugary"

sa "$D/purchyearfull.dta",replace


clear
set obs 365

gen sodaN = _n


u "$D/purchyearfull.dta",clear

keep if sodapurch==1

gen hcl = class<3

replace sodaN = int(sodaN+0.5)
 
keep hhno indvno year agecat asgrp eegrp hcl sodaN

expand sodaN
sort hhno indvno year  

foreach v in agecat asgrp eegrp hcl{
	egen `v'_m = mode(`v'),by(hhno indvno) minmode
}
bysort hhno indvno: keep if _n==1
su hhno agecat_m asgrp_m eegrp_m hcl_m

keep hhno indvno agecat_m asgrp_m eegrp_m hcl_m

foreach v in agecat asgrp eegrp hcl {
	rename `v'_m `v'
}

sa "$D/hhpurch_base.dta",replace


*************************************************************************************************
**Describe T dimension of data
*************************************************************************************************

u "$P0/all_purchases.dta",clear

keep dmindex
bysort dmindex: gen N = _N
bysort dmindex: keep if _n==1

gen     group = 1 if N<25
replace group = 2 if N>=25 & N<50
replace group = 3 if N>=50 & N<75
replace group = 4 if N>=75 & N<100
replace group = 5 if N>=100 & N<250
replace group = 6 if N>=250

gen i0 = 1

collapse (sum) i,by(group)

egen tot = sum(i)
gen perc0 = (i/tot)*100
drop tot

sa "$D/T_out.dta",replace


*************************************************************************************************
**Describe retailer dimension of data
*************************************************************************************************

u "$P0/all_purchases.dta",clear

gen i0 = 1

collapse (sum) i0,by(rm)

egen sum = sum(i0)
gen share = 100*(i0/sum)

format %9.1f share

gen store = rm if rm<4
replace store = 4 if rm==6
replace store = 5 if rm==5
replace store = 6 if rm==4
lab def store 1 "National store" 2 "" 3 "Vending machines" 4 "Convenience store" 5 "" 6 ""
lab val store store

gen store2 = store
lab def store2 1 "Large" 2 "Small" 3 "" 4 "North" 5 "Midlands" 6 "South"
lab val store2 store2

bysort store: keep if _n==1

format %9.0fc i0

sa "$D/storestats.dta",replace



*************************************************************************************************
***Describe products
*************************************************************************************************

u "$P0/prices.dta",clear

collapse (mean) price,by(prodagg)

sa "$D/mean_price.dta",replace

u "$P0/all_purchases.dta",clear

gen i0 = 1

keep if product<199

collapse (sum) i0,by(product prodagg brand firm)

egen sum = sum(i0)
gen share = 100*(i0/sum)

merge m:1 prodagg using "$D/mean_price.dta"

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
31 "Other" 32 "Other Diet"
110 "Fruit juice" 120 "Flavoured milk" 130 "Fruit water" 140 "Water";
#delimit cr
lab val product product

sa "$D/productstats.dta",replace



*************************************************************************************************
**Describe soda purchasers and sugar by age, total dietary sugar and equivalized sugar
*************************************************************************************************

u "$D/purchyearfull.dta",clear

foreach v in sodasugars sodaN sodatax sodabot {
	replace `v' = . if sodapurch==0
}

gen i = 1

collapse (mean) sodapurch sodasugars sodaN sodatax sodabot (sum) i,by(agecat)

egen base = sum(i)
gen frac = (i/base)*100

order agecat frac sodapurch sodasugars sodaN sodatax sodabot
drop i base


xpose,clear var

drop if _n==1
gen     v = 1 if _var=="frac"
replace v = 2 if _var=="sodapurch"
replace v = 3 if _var=="sodasugars"
replace v = 4 if _var=="sodaN"
replace v = 5 if _var=="sodatax"
replace v = 6 if _var=="sodabot"
lab def v 1 "\% of sample" 2 "Fraction of soft drink purchasers" 3 "Mean sugar from soft drinks per year (g)" 4 "Mean number of purchases per year" 5 "Fraction of sugary products" 6  "Fraction of 500ml bottles"
lab val v vs

sort v 

foreach n of numlist 1(1)6 {
	gen temp1 = round(v`n',1)
	gen temp2 = round(v`n',0.1)
	gen temp3 = round(v`n',0.01)
	format temp1 %9.2g
	format temp2 %9.2g
	format temp3 %9.2g
	replace v`n' = temp1 if _n==3	
	replace v`n' = temp2 if _n==1|_n==4
	replace v`n' = temp3 if _n==2|_n==5|_n==6
	drop temp*
}

sa "$D/agestats.dta",replace

u "$D/purchyearfull.dta",clear
   
gen i = 1
merge m:1 i using "$D/centiles.dta"
drop _m i

gen bound = .
foreach n of numlist 1(1)9 {
	replace bound = exp`n'0 if eegrp==`n'
}

su annexp_eq
centile annexp_eq,centile(99)
replace bound = r(c_1) if eegrp==10

foreach v in sodasugars sodaN sodatax sodabot {
	replace `v' = . if sodapurch==0
}

collapse (mean) sodapurch sodasugars sodaN sodatax sodabot bound,by(eegrp)

order eegrp bound sodapurch sodasugars sodaN sodatax sodabot


xpose,clear var

drop if _n==1
gen     v = 1 if _var=="bound"
replace v = 2 if _var=="sodapurch"
replace v = 3 if _var=="sodasugars"
replace v = 4 if _var=="sodaN"
replace v = 5 if _var=="sodatax"
replace v = 6 if _var=="sodabot"
lab def v 1 "Upper bound of decile" 2 "Fraction of soft drink purchasers" 3 "Mean sugar from soft drinks per year (g)" 4 "Mean number of purchases per year" 5 "Fraction of sugary products" 6  "Fraction of 500ml bottles"
lab val v v

sort v 

foreach n of numlist 1(1)10 {
	gen temp1 = round(v`n',1)
	gen temp2 = round(v`n',0.1)
	gen temp3 = round(v`n',0.01)
	format temp1 %9.2g
	format temp2 %9.2g
	format temp3 %9.2g
	replace v`n' = temp1 if _n==3	
	replace v`n' = temp2 if _n==1|_n==4
	replace v`n' = temp3 if _n==2|_n==5|_n==6
	drop temp*
}

sa "$D/expstats.dta",replace


u "$D/purchyearfull.dta",clear

gen i = 1
merge m:1 i using "$D/centiles.dta"
drop _m i

gen bound = .
foreach n of numlist 1(1)9 {
	replace bound = sug`n'0 if asgrp==`n'
}
su annaddsr
centile annaddsr,centile(99)
replace bound = r(c_1) if asgrp==10


gen i = 1

foreach v in sodasugars sodaN sodatax sodabot {
	replace `v' = . if sodapurch==0
}

collapse (mean) sodapurch sodasugars sodaN sodatax sodabot bound,by(asgrp)

order asgrp bound sodapurch sodasugars sodaN sodatax sodabot


xpose,clear var

drop if _n==1
gen     v = 1 if _var=="bound"
replace v = 2 if _var=="sodapurch"
replace v = 3 if _var=="sodasugars"
replace v = 4 if _var=="sodaN"
replace v = 5 if _var=="sodatax"
replace v = 6 if _var=="sodabot"
lab def v 1 "Upper bound of deciles" 2 "Fraction of soft drink purchasers" 3 "Mean sugar from soft drinks per year (g)" 4 "Mean number of purchases per year" 5 "Fraction of sugary products" 6  "Fraction of 500ml bottles"
lab val v v

sort v 

foreach n of numlist 1(1)10 {
	gen temp1 = round(v`n',1)
	gen temp2 = round(v`n',0.1)
	gen temp3 = round(v`n',0.01)
	format temp1 %9.2g
	format temp2 %9.2g
	format temp3 %9.2g
	replace v`n' = temp1 if _n==3	
	replace v`n' = temp2 if _n==1|_n==4
	replace v`n' = temp3 if _n==2|_n==5|_n==6
	drop temp*
}

sa "$D/sugstats.dta",replace
