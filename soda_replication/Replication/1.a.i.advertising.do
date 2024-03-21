

*******************************************************
***Advertising data
*******************************************************

u "M:\TNS\extractedfiles\index_files\dates_detail.dta" ,clear

drop date
gen long date=year*10000+month*100+dayofmonth

drop yearweek yearweek_new demyear dayofweek weekday dayofmonth
drop if date<20090000|date>20150000

egen group = group(week)
sort date
bysort week: gen temp = month if _n==4
egen temp2 = min(temp),by(week)
replace month = temp2
drop temp temp2
bysort week: gen temp = year if _n==4
egen temp2 = min(temp),by(week)
replace year = temp2
drop temp temp2

drop week
rename group week

sort date
gen day = _n

keep date week
rename week week_f

merge 1:1 date using "$P\week.dta"
drop _m

sa "$P\week_ad.dta",replace
	
forv n=2009/2014 {
	
	u "M:\Advertising\Disaggregate\Data\2009-2014\Drinks2009-2014\Drinks_`n'.dta",clear

	merge m:1 date using "$P\week_ad.dta"
	keep if _m==3
	drop _m
	
	gen temp = lower(channel)
	drop if regexm(temp,"ulster")==1

	gen     regdis = 1 if regexm(temp,"carlton")==1|regexm(temp,"london")==1
	replace regdis = 2 if (regexm(temp,"central")==1|regexm(temp,"midlands")==1)&regexm(temp,"comedy")==0
	replace regdis = 3 if regexm(temp,"tyne tees")==1|regexm(temp,"north east")==1
	replace regdis = 4 if regexm(temp,"yorkshire")==1
	replace regdis = 5 if regexm(temp,"granada")==1|regexm(temp,"north west")==1|regexm(temp,"c4macro - north")==1|regexm(temp,"c5macro - north")==1
	replace regdis = 6 if regexm(temp,"anglia")==0&(regexm(temp,"meridian")==1|regexm(temp,"sth,sth east & chan")==1|regexm(temp,"sth,sth e & chan")==1|regexm(temp,"south england")==1|regexm(temp,"south east")==1)|regexm(temp,"c4macro - south")==1
	replace regdis = 7 if regexm(temp,"scotland")==1|regexm(temp,"border")==1
	replace regdis = 8 if regexm(temp,"anglia")==1|regexm(temp,"east of england")==1|regexm(temp,"c5 - east")==1
	replace regdis = 9 if regexm(temp,"wales")==1|index(temp,"s4")>0|regexm(temp,"htv west")==1|regexm(temp,"htv west")==1|regexm(temp,"breakfast - west")==1|regexm(temp,"midwest")==1|regexm(temp,"macro - west")==1|regexm(temp,"t hd - west")==1|regexm(temp,"c4 - west")==1
	replace regdis = 10 if regexm(temp,"westcountry")==1|regexm(temp,"south west")==1|regexm(temp,"hd - westc")==1
	replace regdis = 100 if regdis==.

	lab def regdis 1 "London" 2 "Midlands" 3 "North east" 4 "Yorkshire"  5 "Lancashire" 6 "South" 7 "Scotland"  8 "Anglia" 9 "Wales" 10 "South west" 100"National"   
	lab val regdis regdis
	
	collapse (sum) expenditure,by(brand regdis week_f week year month)
	
	sa "$P/`n'.dta",replace
}
	
u "$P\2009.dta",clear

forv n=2009/2014 {
	append using "$P/`n'.dta"
}

gen brand_cl = lower(brand)
drop brand

gen brand = 0

**Coca Cola

replace brand = 1 if regexm(brand_cl,"coca cola")==1 & regexm(brand_cl,"oasis")==0&regexm(brand_cl,"fruice")==0
tab brand_cl if brand==1

tab brand_cl if regexm(brand_cl,"coca cola")==1 & brand==0

**Dr Pepper

replace brand = 2 if regexm(brand_cl,"dr pepper")==1 
tab brand_cl if brand==2

**Fanta

replace brand = 3 if regexm(brand_cl,"fanta")==1
tab brand_cl if brand==3

**Cherry

tab brand_cl if regexm(brand_cl,"cherry")==1

**Oasis

replace brand = 5 if regexm(brand_cl,"oasis")==1  
tab brand_cl if brand==5

**Pepsi

replace brand = 6 if regexm(brand_cl,"pepsi")==1 & regexm(brand_cl,"mountain dew")==0
tab brand_cl if brand==6

tab brand_cl if regexm(brand_cl,"pepsi")==1 & brand==0

**Lucozade Energy

tab brand_cl if regexm(brand_cl,"lucozade")==1 & regexm(brand_cl,"sport")==0

**Ribena

replace brand = 8 if regexm(brand_cl,"ribena")==1
tab brand_cl if brand==8

**Sprite

replace brand = 9 if regexm(brand_cl,"sprite")==1
tab brand_cl if brand==9

**Irn Bru

replace brand = 10 if regexm(brand_cl,"irn bru")==1
tab brand_cl if brand==10

**Other

**Fruit juice

replace brand = 110 if regexm(brand_cl,"tropicana")==1
tab brand_cl if brand==110

**Flavoured milk

replace brand = 120 if regexm(brand_cl,"yazoo")==1|regexm(brand_cl,"frijj")==1
tab brand_cl if brand==120

**Fruit Water

replace brand = 130 if regexm(brand_cl,"touch of fruit water")==1
tab brand_cl if brand==130

**Water

replace brand = 140 if regexm(brand_cl,"evian")==1|(regexm(brand_cl,"volvic")==1&regexm(brand_cl,"touch of fruit water")==0)|regexm(brand_cl,"stathmore")==1|regexm(brand_cl,"buxton")==1|regexm(brand_cl,"glaceau")==1|regexm(brand_cl,"isklar")==1|regexm(brand_cl,"pure life")==1|regexm(brand_cl,"san pellegrino")==1
tab brand_cl if brand==140

tab brand_cl if brand==0

lab def brand 1 "Coke" 2 "Dr Pepper" 3 "Fanta" 4 "Cherry Coke" 5 "Oasis" 6 "Pepsi" 7 "Lucozade Energy" 8 "Ribena" 100 "Other" 110 "Fruit juice" 120 "Flavoured milk" 130 "Fruit water" 140 "Water"
lab val brand brand

table brand       ,c(sum exp)
table regdis      ,c(sum exp)
table brand regdis,c(sum exp)

drop if brand==0

sa "$P/alladv.dta",replace

clear
set obs 314
gen week_f = _n
gen week = week_f-22
replace week = . if week<1 

sa "$P/wk_n.dta",replace

u "$P/alladv.dta",clear

keep if regdis==100

collapse (sum) exp,by(brand week_f)

merge m:1 week_f using "$P/wk_n.dta"
drop _m
replace brand = 1 if exp==.
replace exp = 0 if exp==.

fillin brand week_f
drop _f

egen temp = min(week),by(week_f)
replace week = temp if week==.
drop temp

replace exp = 0 if exp==.
replace exp = exp/100000

rename exp exp_n

sa "$P/nationalad.dta",replace

u "$P/alladv.dta",clear

keep if regdis!=100

collapse (sum) exp,by(brand regdis week_f)

merge m:1 week_f using "$P/wk_n.dta"
drop _m
replace brand = 1 if exp==.
replace regdis = 1 if exp==.
replace exp = 0 if exp==.

fillin brand regdis week_f
drop _f

egen temp = min(week),by(week_f)
replace week = temp if week==.
drop temp

replace exp = 0 if exp==.
replace exp = exp/100000

merge m:1 brand week_f using "$P/nationalad.dta"
drop _m

replace expe = exp_n      if expe
replace expe = expe+exp_n
drop exp_n

rename exp adflow

sort regdis brand week_f
 
gen adstock=0

by regdis brand: gen N = _N
by regdis brand: gen n = _n

foreach x of numlist 0(1)314 {
	gen NN = N-n-`x'
	gen     temp1 = adflow*(0.9^NN)
	replace temp1 = . if NN<0
	egen    temp2 = sum(temp1),by(regdis brand)
	replace adstock = temp2 if NN==0
	drop NN temp1 temp2
}

drop if week==.
drop week_f
drop n N
order regdis brand week adflow adstock

sa "$P/addata.dta",replace

*******************************************************
***Weather data
*******************************************************

u "$P/all_purchases.dta",clear

keep hhno year month
bysort hhno year month: keep if _n==1

rename year demyear
merge m:1 hhno demyear using "M:\TNS\extractedfiles\panel_data\hhpanel_all.dta" , keepusing(demyear postcode)
rename demyear year
sort hhno year month
by hhno: replace postcode=postcode[_n+1] if postcode==""
by hhno: replace postcode=postcode[_n+1] if postcode==""
drop if _m==2|month==.
drop _m

rename postcode postcode1
merge m:1 postcode using "$P/neareststation.dta"
drop if _m==2
drop _m

merge m:1 location year month using "$P/weather.dta"
drop if _m==2
drop _m

foreach x in tmax tmin rain {
	bysort year month: egen temp = mean(`x')
	replace `x' = temp if `x' == .
	drop temp
}

keep hhno year month tmax tmin rain

sa "$P/hhym_weather_string.dta", replace 


