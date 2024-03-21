
clear
cap log close
set more off

global P    "$cd"
global Prog "$pg"

**************************************************************************
**A) Construct product attributes
**************************************************************************

********************************
**FOTG
********************************

u "M:/TNS/extractedfiles/fotg_data/purchase_all.dta",clear

drop if year==2015
drop if year==2014 & month==12 & dayofmonth>28
keep prodcode year shopcode

sa "$P/allprodcodes.dta",replace

u "M:/TNS/extractedfiles/fotg_data/rf1545_16.dta",clear

gen i = 1

append using "M:/TNS/extractedfiles/fotg_data/rf1545_12.dta"
replace i = 2 if i==.

egen min = min(i),by(prodcode)
keep if i==min
drop i min

sa "$P/fotg_rawattributes.dta",replace

u "$P/fotg_rawattributes.dta",clear

keep if totalfotgmarket=="Soft Drinks"

keep prodcode productdesc brand totalfotgsector manufacturer

merge 1:m prodcode using "$P/allprodcodes.dta"
keep if _m==3
drop _m

bysort brand: drop if _N<1000

rename brand brand_old

gen diet = index(brand_old,"Diet")>0|index(brand_old,"Zero")>0|index(brand_old,"Light")>0|index(brand_old,"Mx")>0|index(brand_old,"Max")>0|index(brand_old,"Lite")>0|index(brand_old,"Free")>0|index(brand_old,"Lght")>0|index(brand_old,"Dt")>0|index(brand_old,"NAS")>0|index(brand_old,"Beach")

gen     brand = 1 if (index(brand_old,"Coca Cola")>0|index(brand_old,"Diet Coke")>0)
replace brand = 2 if index(brand_old,"Dr. P")>0|index(brand_old,"Dr.P")>0
replace brand = 3 if index(brand_old,"Fanta")>0
replace brand = 4 if index(brand_old,"Cherry Coke")>0
replace brand = 5 if index(brand_old,"Oasis")>0
replace brand = 6 if (index(brand_old,"Pepsi")>0)
replace brand = 7 if (index(brand_old,"Luco")>0)& index(brand_old,"Sport")==0&index(brand_old,"Sprt")==0
replace brand = 8 if index(brand_old,"Ribena")>0
replace brand = 9  if index(brand_old,"Sprite")>0
replace brand = 10 if index(brand_old,"Irn Bru")>0


replace brand = 100 if brand==. & (totalfotgsector=="Bottled Colas"|totalfotgsector=="Canned Colas"|totalfotgsector=="Bottled Flavours"|totalfotgsector=="Canned Flavours")
replace brand = 100 if brand==. & (brand_o=="Vimto Reg")
replace brand = 100 if brand==. & (index(brand_old,"Luco")>0 & (index(brand_old,"Sport")>0|index(brand_old,"Sprt")>0))
replace brand = 100 if brand==. & index(brand_old,"Lipton")>0 
replace brand = 100 if brand==. & index(brand_old,"Powerade")>0 
replace brand = 100 if brand==. & index(brand_old,"Frt Shoot")>0 

replace brand = 110 if (index(lower(brand_old),"fruit")>0|index(lower(brand_old),"smoothie")>0|index(lower(brand_old),"tropicana")>0|index(lower(brand_old),"pr jc")>0) & brand==.
replace brand = 120 if index(lower(brand_old),"milk")>0 & diet==0 & brand==.
replace brand = 130 if totalfotgsector=="Mineral Water" & index(lower(brand_old),"frt")>0 & brand==.
replace brand = 140 if totalfotgsector=="Mineral Water" & brand==.

lab def brand 1 "Coke" 2 "Dr Pepper" 3 "Fanta" 4 "Cherry Coke" 5 "Oasis" 6 "Pepsi" 7 "Lucozade Energy" 8 "Ribena" 9 "Sprite" 10 "Irn Bru" 100 "Other" 110 "Fruit juice" 120 "Flavoured milk" 130 "Fruit water" 140 "Water"
lab val brand brand

gen out = 0

gen     firm = 1 if manufacturer=="Coca Cola Bottlers"| manufacturer=="Coca Cola Enterprises"
replace firm = 2 if manufacturer=="Britvic / Pepsico"
replace firm = 3 if manufacturer=="Lucozade Ribena Suntory"
replace firm = 4 if manufacturer=="A.G.Barr Plc"
replace firm = 100 if brand>=100

lab def firm 1 "CocaCola" 2 "Pepsico" 3 "GSK"  4 "Barrs" 100 "Outside"
lab val firm firm

*** Volume is mismeasured. Replace with npacks*size where size is from productdesc
gen pd_temp = lower(word(productdesc,-1))
gen pack = .
forval x=8(-1)3 {
   replace pack = real(substr(pd_temp,-`x',`x'-2)) if pack==. & strpos(pd_temp,"-")==0&real(substr(pd_temp,-2,1))==.
}
forval x=8(-1)2 {
   replace pack = real(substr(pd_temp,-`x',`x'-1)) if pack==. & strpos(pd_temp,"-")==0&real(substr(pd_temp,-2,1))!=.
}
drop if pack<200

**Product: Coke
gen     product = 1  if brand==1  & pack==330 & diet==0
replace product = 2  if brand==1  & pack==500 & diet==0
replace product = 3  if brand==1  & pack==330 & diet==1
replace product = 4  if brand==1  & pack==500 & diet==1

forval n =1/4 {
	tab productdesc if product==`n'
}
tab productdesc if brand==1 & product==.

**Product: Dr Pepper
replace product = 5  if brand==2  & pack==330 & diet==0
replace product = 6  if brand==2  & pack==500 & diet==0
replace product = 7  if brand==2  & pack==330 & diet==1
replace product = 8  if brand==2  & pack==500 & diet==1

forval n =5/8 {
	tab productdesc if product==`n'
}
tab productdesc if brand==2 & product==.

**Product: Fanta
replace product = 9  if brand==3  & pack==330 & diet==0
replace product = 10 if brand==3  & pack==500 & diet==0
replace product = 11 if brand==3  & pack==330 & diet==1
replace product = 12 if brand==3  & pack==500 & diet==1

forval n =9/12 {
	tab productdesc if product==`n'
}
tab productdesc if brand==3 & product==.

**Product: Cherry Coke
replace product = 13 if brand==4  & pack==330 & diet==0
replace product = 14 if brand==4  & pack==500 & diet==0
replace product = 15 if brand==4  & pack==330 & diet==1
replace product = 16 if brand==4  & pack==500 & diet==1

forval n =13/16 {
	tab productdesc if product==`n'
}
tab productdesc if brand==4 & product==.

**Product: Oasis
replace product = 17 if brand==5 & pack==500 & diet==0
replace product = 18 if brand==5 & pack==500 & diet==1

forval n =17/18 {
	tab productdesc if product==`n'
}
tab productdesc if brand==5 & product==.

**Product: Pepsi
replace product = 19 if brand==6  & pack==330             & diet==0
replace product = 20 if brand==6  & (pack==500|pack==600) & diet==0
replace product = 21 if brand==6  & pack==330             & diet==1
replace product = 22 if brand==6  & (pack==500|pack==600) & diet==1

forval n =19/22 {
	tab productdesc if product==`n'
}
tab productdesc if brand==6 & product==.

**Product: Lucozade
replace product = 23 if brand==7 & (pack==330|pack==380) & diet==0
replace product = 24 if brand==7 & pack==500             & diet==0

forval n =23/24 {
	tab productdesc if product==`n'
}
tab productdesc if brand==7 & product==.

**Product: Ribena
replace product = 25 if brand==8  & pack==288 & diet==0
replace product = 26 if brand==8  & pack==500 & diet==0
replace product = 27 if brand==8  & pack==288 & diet==1
replace product = 28 if brand==8  & pack==500 & diet==1

forval n =25/28 {
	tab productdesc if product==`n'
}
tab productdesc if brand==8 & product==.

**Product: Sprite
replace product = 29 if brand==9 & pack==330 & diet==0
replace product = 30 if brand==9 & pack==500 & diet==0

forval n =29/30 {
	tab productdesc if product==`n'
}
tab productdesc if brand==9 & product==.

**Product: Irn Bru
replace product = 31 if brand==10 & pack==330 & diet==0
replace product = 32 if brand==10 & pack==500 & diet==0
replace product = 33 if brand==10 & pack==330 & diet==1
replace product = 34 if brand==10 & pack==500 & diet==1

forval n =31/34 {
	tab productdesc if product==`n'
}
tab productdesc if brand==10 & product==.

replace product = 35 if brand==100 & diet==0
replace product = 36 if brand==100 & diet==1

forval n =35/36 {
	tab productdesc if product==`n'
}
tab productdesc if brand==100 & product==.

tab brand_old if brand==110
tab brand_old if brand==120
tab brand_old if brand==130
tab brand_old if brand==140

tab brand_old if out==1

foreach n of numlist 1(1)10 {
	replace out = 1 if brand==`n' & product==.
}

tab product
replace out = 1 if product==7|product==11|product==15|product==27
drop if out==1

egen prod = group(product)
drop product
rename prod product

replace product = 110 if brand==110
replace product = 120 if brand==120
replace product = 130 if brand==130
replace product = 140 if brand==140

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

lab val product product
numlabel product,add

bysort prodcode: gen n = 1 if _n==1
egen noUPC=sum(n),by(product)

bysort product: gen noTrans = _N
gen NT = _N
gen shTrans = (noTrans/NT)*100

format %9.1f shTrans
table product,c(mean noTrans mean shTrans mean noUPC)
table brand_old if product==31|product==32

keep prodcode productdesc manufacturer brand_old totalfotgsector diet firm pack product brand year
tab brand

sa "$P/prodcode_purchases.dta",replace

u "$P/prodcode_purchases.dta",clear

bysort prodcode: keep if _n==1

gen     prodagg = 1  if product==1|product==3
replace prodagg = 2  if product==2|product==4
replace prodagg = 3  if product==5
replace prodagg = 4  if product==6|product==7
replace prodagg = 5  if product==8
replace prodagg = 6  if product==9|product==10
replace prodagg = 7  if product==11
replace prodagg = 8  if product==12|product==13
replace prodagg = 9  if product==14|product==15
replace prodagg = 10 if product==16|product==18
replace prodagg = 11 if product==17|product==19
replace prodagg = 12 if product==20
replace prodagg = 13 if product==21
replace prodagg = 14 if product==22
replace prodagg = 15 if product==23|product==24
replace prodagg = 16 if product==25
replace prodagg = 17 if product==26
replace prodagg = 18 if product==27|product==29
replace prodagg = 19 if product==28|product==30
replace prodagg = 20 if product==31
replace prodagg = 21 if product==32

replace prodagg = 22 if product==110
replace prodagg = 23 if product==120
replace prodagg = 24 if product==130
replace prodagg = 25 if product==140


#delimit ;
lab def prodagg 
1  "Coca Cola 330" 2  "Coca Cola 500"
3  "Dr Pepper 330" 4  "Dr Pepper 500" 
5  "Fanta 330" 6 "Fanta 500" 
7  "Cherry Coke 330" 8 "Cherry Coke 500"
9 "Oasis 500"
10 "Pepsi 330" 11 "Pepsi 500"  
12 "Lucozade Energy 380" 13 "Lucozade Energy 500" 
14 "Ribena 288" 15 "Ribena 500" 
16 "Sprite 330" 17 "Sprite 500"
18 "Irn Bru 330" 19 "Irn Bru 500"
20 "Other" 21 "Other Diet"
22 "Fruit juice" 23 "Flavoured milk" 24 "Fruit water" 25 "Water";
#delimit cr
lab val prodagg prodagg

keep prodcode brand diet pack firm product prodagg

sa "$P/attributes.dta",replace

**************************************************************************
**B) Sample of households
**************************************************************************

u "M:/TNS/extractedfiles/index_files/dates_detail.dta" ,clear

drop date
gen long date=year*10000+month*100+dayofmonth

drop yearweek yearweek_new demyear dayofweek weekday dayofmonth
drop if date<20090601|date>20150000

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

drop if week==292

sa "$P/week.dta",replace

u "M:/TNS/extractedfiles/index_files/hh_daily_expenditure_16.dta",clear

merge m:1 date using "$P/week.dta"
drop if _m==2
replace day = 0    if date<20090601
replace day = 9999 if date>20141228
drop _m

egen inentry = min(day),by(hhno)
egen inexit  = max(day),by(hhno)

collapse (mean) inentry inexit,by(hhno)

drop if inentry==0&inexit==0
drop if inentry==9999&inexit==9999

sa "$P/hhno_WPdates.dta",replace

u "M:/TNS/extractedfiles/fotg_data/purchase_all.dta",clear

drop if year==2015
drop if year==2014 & month==12 & dayofmonth>28

format date %td
keep  hhno indvno date month year week demyear prodcode npacks expenditure volume shopcode
order hhno indvno date month year week demyear prodcode npacks expenditure volume shopcode
drop if exp==0|vol==0
drop if npacks>2

gen day=day(date)
drop date
gen long date=year*10000+month*100+day
drop month year day

drop week
merge m:1 date using "$P/week.dta"
drop if _m==2
drop _m

merge m:1 prodcode using "$P/attributes.dta",keepusing(prodcode prodagg)
drop if _m==2
gen inmarket = _m==3
gen p=exp/npacks
gen drop = 0
su prodagg
local l = r(max)
forv n=1/`l' {
	centile p if prodagg==`n',centile(1 99)
	replace drop = 1 if (p<r(c_1)|p>r(c_2)) & prodagg==`n'
}	
centile p if inmarket==0,centile(1 99)
replace drop = 1 if (p<r(c_1)|p>r(c_2)) & inmarket==0
drop if drop==1
drop _m inmarket p drop

merge m:1 prodcode using "$P/fotg_rawattributes.dta",keepusing(totalfotgmarket)
keep if _m==3
drop _m

gen     cat = 1 if prodagg!=.
replace cat = 2 if totalfotgmarket=="Chocolate Confectionery"|totalfotgmarket=="Cereal Bars"
replace cat = 3 if totalfotgmarket=="Crisps"|totalfotgmarket=="Savoury Snacks"|totalfotgmarket=="Fruit Salad"

lab def cat 1 "Drinks purchase" 2 "Confectionery" 3 "Outside option"
lab val cat cat

drop totalfotgmarket

sa "$P/FOTGpurchases.dta",replace

u "$P/FOTGpurchases.dta",clear

merge m:1 prodcode using "$P/attributes.dta"
drop if _m==2
drop _m

gen soda  = brand<=100
gen drink = cat==1
gen snack = cat!=.

collapse (sum) soda drink snack,by(hhno indvno date day week demyear)

egen outentry = min(day),by(hhno indvno)
egen outexit  = max(day),by(hhno indvno)

merge m:1 hhno using "$P/hhno_WPdates.dta"
keep if _m==3
drop _m

drop if outentry<inentry
drop if outexit>inexit
drop inentry outentry inexit outexit

merge m:1 hhno indvno using "M:/TNS/extractedfiles/fotg_data/age_sex_full.dta",keepusing(hhno indvno)
keep if _m==3
drop _m

bysort hhno indvno: gen Tfotg = _N

foreach v in soda drink snack {
	gen temp = `v'>0
	egen T`v' = sum(temp),by(hhno indvno)
	drop temp
}

egen entry = min(day),by(hhno indvno)
egen exit  = max(day),by(hhno indvno)
gen span = exit-entry+1

collapse (mean) Tfotg Tsoda Tdrink Tsnack entry exit span,by(hhno indvno)

lab var Tfotg   "Days observed making fotg purchase"
lab var Tsoda   "Days observed making soft drinks purchase" 
lab var Tdrink  "Days observed making drinks purchase"
lab var Tsnack  "Days observed making snacks purchase"
lab var entry   "Day of entry to sample"
lab var exit    "Day of exit from sample"
lab var span    "Days between entry and exit"

sa "$P/indvno_panelstats.dta",replace

u "$P/indvno_panelstats.dta",clear

gen drop1 = Tfotg<25
tab drop1
drop if drop1==1
drop drop1

gen indemand = Tsnack>14 & Tsoda>9
tab indemand

keep hhno indvno indemand entry exit

sa "$P/indvno_sample.dta",replace

bysort hhno: keep if _n==1
keep hhno

sa "$P/hhno_sample.dta",replace

**************************************************************************
**C) Drinks purchases
**************************************************************************

u "$P/FOTGpurchases.dta",clear

keep if cat!=.

merge m:1 prodcode using "$P/attributes.dta"
drop if _m==2
drop _m

merge m:1 hhno indvno using "$P/indvno_sample.dta"
keep if indemand==1
drop _m indemand entry exit 

merge m:1 shopcode using "M:/TNS/extractedfiles/fotg_data/shopcodes.dta"
drop if _m==2
drop _m

gen     storetype = 1 if fascia=="Aldi"|fascia=="Asda"|fascia=="Lidl"|fascia=="Morrisons"|fascia=="Safeway"|fascia=="Sainsbury's (Supermarket)"|fascia=="Sainsbury's Local"|fascia=="Tesco (Supermarket)"|fascia=="Tesco Express"|fascia=="Tesco Extra"|fascia=="Tesco Metro"|fascia=="Waitrose"
replace storetype = 2 if fascia=="Boots"|fascia=="Budgens"|fascia=="Costcutter"|fascia=="Farm Foods"|fascia=="Greggs"|fascia=="Holland And Barrett"|fascia=="Iceland"|fascia=="Londis"|fascia=="Marks & Spencer"|fascia=="Netto"|fascia=="Nisa"|fascia=="Poundstretcher"|fascia=="Pret A Manger"|fascia=="Savacentre"|fascia=="Savers"|fascia=="Somerfield"|fascia=="Spar"|fascia=="Spar 8 Til Late"|fascia=="Subway"|fascia=="Superdrug"|fascia=="Thorntons"|fascia=="Total Co-Op Grocers"|fascia=="Toys R Us"|fascia=="Upper crust"|fascia=="W H Smith"|fascia=="Wilkinsons"
replace storetype = 3 if fascia=="Vending machine"
replace storetype = 4 if storetype==.
 
lab def st 1 "National-large" 2 "National-small" 3 "Vending machine" 4 "Regional" 
lab val storetype st

merge m:1 hhno indvno using "M:/TNS/extractedfiles/fotg_data/age_sex_full.dta",keepusing(region regdis)
keep if _m==3
drop _m

egen tm = group(year month)
gen     rm = 1 if storetype==1
replace rm = 2 if storetype==2
replace rm = 3 if storetype==3
replace rm = 4 if storetype==4 & region==1
replace rm = 5 if storetype==4 & region==2
replace rm = 6 if storetype==4 & region==3

lab def reg 1 "South" 2 "Midlands" 3 "North"
lab val region reg

lab def rm 1 "National-large" 2 "National-small" 3 "Vending machine"  4 "Regional - south" 5 "Regional - midlands" 6 "Regional - north"
lab val rm rm

sa "$P/snackpurchases_raw.dta",replace

u "$P/snackpurchases_raw.dta",clear

keep if cat==1

gen i = 1

collapse (sum) i,by(prodagg rm)

fillin prodagg rm 
replace i = 0 if _f==1
drop _f

gen notavail = i<100

egen sum = sum(i),by(notavail)
table notavail,c(mean sum)
tab notavail
drop sum i

sa "$P/rmproduct_avail.dta",replace

u "$P/snackpurchases_raw.dta",clear

merge m:1 prodagg rm using "$P/rmproduct_avail.dta"
drop if notavail==1
drop notavail _m rm

gen inside  = cat==1
gen inout   = cat==2

egen temp = max(inside),by(hhno indvno date)
drop if inside==0 & temp==1
drop temp 
gen nonout = inside+inout
egen temp = max(nonout),by(hhno indvno date)
drop if nonout==0 & temp==1
drop temp nonout

bysort hhno indvno date inside: gen n = _n
drop if n>1 & inside==0
replace st=. if inside==0
drop n 

bysort hhno indvno date: gen n = _n
bysort hhno indvno date: gen N = _N
drop n N

sort hhno indvno date product prodcode npacks expenditure volume shopcode
set seed 27
drawnorm x
sort hhno indvno date x
by hhno indvno date: gen temp=_n
keep if temp==1
drop x temp

bysort hhno indvno product: gen f = 1 if _n==1
replace f = 0 if inside==0
egen sum = sum(f),by(hhno indvno)
bysort hhno indvno: gen n = _n
drop if sum==1
drop sum f n

replace product = 199 if cat==2
replace prodagg = 199 if cat==2
replace brand   = 199 if cat==2
replace firm    = 199 if cat==2
replace product = 999 if cat==3
replace prodagg = 999 if cat==3
replace brand   = 999 if cat==3
replace firm    = 999 if cat==3

foreach v in diet inside pack {
	replace `v' = 0 if product==199|product==999
}

keep hhno indvno date month year week day tm region regdis storetype product prodagg diet brand firm inside pack     

gen sugary = 1-diet
replace sugary = 0 if product==140|product==999

gen drink   = brand<199
gen outside = brand>=199

egen sum_drink   = sum(drink),by(hhno indvno)
egen sum_outside = sum(outside),by(hhno indvno)

gen indrink = sum_drink>10 & sum_outside>10

drop drink outside sum_*

gen temp = sugary 
egen mean_s = mean(temp),by(hhno indvno)
gen     sugar_prev = 1 if mean_s==1
replace sugar_prev = 2 if mean_s==0
replace sugar_prev = 3 if mean_s!=0&mean_s!=1&mean_s!=. 
lab def fin 1 "All" 2 "None" 3 "Switch"
lab val sugar_prev fin
drop temp mean_s

gen     order = 1 if sugar_prev==3
replace order = 2 if sugar_prev==2
replace order = 3 if sugar_prev==1

lab def order 1 "Switch" 2 "None" 3 "All" 
lab val order order

bysort hhno indvno: gen n = _n

tab order if n==1
tab order indrink if n==1

egen dmindex = group(hhno indvno)
egen csindex = group(hhno indvno date)
order dmindex csindex

merge 1:1 hhno indvno date using "M:/TNS/extractedfiles/fotg_data/main_retailer.dta", update
drop _m

gen     rm = 1 if storetype==1
replace rm = 2 if storetype==2
replace rm = 3 if storetype==3
replace rm = 4 if storetype==4 & region==1
replace rm = 5 if storetype==4 & region==2
replace rm = 6 if storetype==4 & region==3
lab val rm rm
order rm,after(tm)

label var dmindex            "Decision maker index"
label var csindex            "Choice situation index"
label var hhno               "Index of hh"
label var indvno             "Index of ind in hh"

label var date               "Date"
label var day                "Day"
label var week               "Week"
label var month              "Month"
label var year               "Year"
label var date               "Date"

label var sugar_prev         "Sugar switchers"
label var order              "Switcher indicator"
label var indrink    		 "Include drinks effect"

label var product            "Product"
label var prodagg			 "Product agg over diet"	
label var brand              "Brand"
label var firm               "Firm"
label var inside             "Inside option"
label var diet				 "Diet soda"
label var sugary             "Product contains sugar"
label var pack				 "Size"
label var storetype          "Retailer type"
label var region             "Region"
label var tm                 "Time market"
label var rm                 "Store/region market"

sa "$P/all_purchases.dta",replace


**************************************************************************
**D) Create price for each product
**************************************************************************

u "$P/snackpurchases_raw.dta",clear

merge m:1 prodagg rm using "$P/rmproduct_avail.dta"
keep if notavail==0
drop notavail _m

gen price = expenditure/npack

gen size = pack
replace size = 500 if product==19|product==31|product==32|product==120|product==130|product==140
replace size = 380 if product==20
replace size = 330 if product==110

replace price = price*(5/6) if pack==600 & (product==19)
replace price = price*(3.8/3.3) if pack==330 & product==20
replace price = price*(330/pack) if product==110
replace price = price*(500/pack) if product==31|product==32|product==120|product==130|product==140

keep prodagg tm rm year month price size

bysort prodagg tm rm: gen N = _N

sa "$P/transaction_prices.dta",replace

collapse (mean) price N size,by(prodagg tm year month rm)

egen prrm=group(prodagg rm)

fillin prrm tm 
tab _f

foreach v in prodagg rm size {
	egen temp = min(`v'),by(prrm)
	replace `v' = temp if `v'==.
	drop temp
}

foreach v in year month {
	egen temp = min(`v'),by(tm)
	replace `v' = temp if `v'==.
	drop temp
}

replace N = 0 if N==.

gen pricetemp = price if N>3
ipolate pricetemp tm,by(prodagg rm) gen(prc)
sort prodagg rm tm
forval l=1/73 {
	by prodagg rm: replace prc = prc[_n+1] if prc==.
	by prodagg rm: replace prc = prc[_n-1] if prc==.
}

drop price
rename prc price

gen price_smooth = 0
su prrm
local l = r(max)
forval n=1/`l'{
    lpoly price tm if prrm==`n',bw(1) gen(x y) at(tm) nograph
    qui replace price_smooth = y if prrm==`n'
    qui drop x y
}

keep  tm year month rm prodagg price price_smooth size 
order tm year month rm prodagg price price_smooth size

sa "$P/prices.dta",replace

**************************************************************************
**E) Create advertising and weather variables
**************************************************************************

do "$Prog/1.a.i.advertising.do"

**************************************************************************
**F) Create stock of at-home soft drinks
**************************************************************************

do "$Prog/1.a.ii.athomeinventories.do"

**************************************************************************
**G) Create data for estimation
**************************************************************************

u "$P/all_purchases.dta",clear

keep dmindex csindex hhno indvno date month year week day tm region regdis rm sugar_prev order indrink

sa "$P/index_vars.dta",replace

u "$P/all_purchases.dta",clear

bysort product: keep if _n==1
keep product prodagg brand firm inside diet sugary    

sa "$P/options_vars.dta",replace

u "$P/all_purchases.dta",clear

keep csindex product
gen choice = 1
fillin csindex product // this creates a cartesian product
drop _fillin
replace choice=0 if choice==.

mer m:1 csindex using "$P/index_vars.dta"
keep if _m==3
drop _m

merge m:1 product using "$P/options_vars.dta"
keep if _m==3
drop _m

merge m:1 hhno day using "$P/athome_inventories.dta",keepusing(invssoft invdsoft invfruit invfmilk invfwater invwater)
drop if _m==2
drop _m

gen     inv = invssoft  if product<100 & sugary==1
replace inv = invdsoft  if product<100 & sugary==0
replace inv = invfruit  if product==110
replace inv = invfmilk  if product==120
replace inv = invfwater if product==130
replace inv = invwater  if product==140
replace inv = 0         if product==199|product==999
replace inv = 0         if inv==.
drop invssoft invdsoft invfruit invfmilk invfwater invwater

****************
**Create choice sets
****************

merge m:1 prodagg rm using "$P/rmproduct_avail.dta",keepusing(prodagg rm notavail)
keep if notavail==0|product==199|product==999
drop notavail _m

drop if sugary==0 & sugar_prev==1 
drop if sugary==1 & sugar_prev==2 

mer m:1 prodagg tm rm using "$P/prices.dta"
foreach v in price price_smooth size {
	replace `v' = 0 if product==199|product==999
}
drop _m

merge m:1 hhno indvno using "M:/TNS/extractedfiles/fotg_data/age_sex_full.dta",keepusing(agegroup gender)
keep if _m==3
drop _m

gen old = agegroup==3
egen group = group(gender old)

lab def gp 1 "Female;<40" 2 "Female;40+" 3 "Male;<40" 4 "Male;<40"
lab val group gp

gen coke         = brand==1
gen drpepper     = brand==2
gen fanta        = brand==3
gen cherry       = brand==4
gen oasis        = brand==5
gen pepsi        = brand==6
gen lucenergy    = brand==7
gen ribena       = brand==8
gen sprite       = brand==9
gen irnbru       = brand==10
gen other        = brand==100
gen fruit        = brand==110
gen milk         = brand==120
gen fruitwater   = brand==130
gen water        = brand==140
gen sugoutside   = brand==199
gen nonoutside   = brand==999

gen drinks = brand<199

gen size288 = size==288 
gen size330 = size==330 
gen size380 = size==380 
gen size500 = size==500

merge m:1 regdis brand week using "$P/addata.dta"
drop if _m==2
tab brand if _m==1
replace adflow = 0  if adflow==.
replace adstock = 0 if adstock==.
drop _m

merge m:1 hhno year month using "$P/hhym_weather_string.dta"
drop if _m==2
drop _m

label var dmindex            "Decision maker index"
label var csindex            "Choice situation index"
label var hhno               "Index of hh"
label var indvno             "Index of ind in hh"
label var sugar_prev         "Sugar switchers"

label var order              "Switcher indicator"
label var indrink   		 "Include drinks effect"
label var group				 "Demographic group"

label var date               "Date"
label var day                "Day"
label var week               "Week"
label var month              "Month"
label var year               "Year"
label var date               "Date"

label var tm                 "Time market"
label var rm                 "Store/region market"

label var product            "Product"
label var prodagg			 "Product agg over diet"	
label var brand              "Brand"
label var firm               "Firm"
label var inside             "Inside option"

label var choice             "1 for option chosen"
label var price              "Option price"
label var price_smooth       "Option price (smoothed)"
label var drinks             "Drinks dummy"
label var sugary             "Nondiet dummy"

label var adflow			 "Weekly adv (£100,000)"	
label var adstock			 "Adv stock (£100,000)"	
label var tmax				 "Monthly max temp"
label var tmin               "Monthly min temp"  
label var rain               "Monthly rainfail"

label var size               "Option size"
label var size288            "Size dummy"
label var size330            "Size dummy"
label var size380            "Size dummy"
label var size500            "Size dummy"

label var coke               "Brand dummy"
label var drpepper           "Brand dummy"
label var fanta              "Brand dummy"
label var cherry             "Brand dummy"
label var oasis              "Brand dummy"
label var pepsi              "Brand dummy"
label var lucenergy          "Brand dummy"
label var ribena             "Brand dummy"
label var sprite             "Brand dummy"
label var irnbru             "Brand dummy"
label var other              "Brand dummy"
label var fruit              "Brand dummy"
label var milk               "Brand dummy"
label var fruitwater         "Brand dummy"
label var water              "Brand dummy"
label var sugoutside     	 "Sugar outside option dummy"
label var nonoutside	     "Outside option dummy"

label var inv				 "At home inventory"

keep  dmindex csindex hhno indvno sugar_prev order indrink group date day week month year date tm rm product prodagg brand firm inside choice price price_smooth drinks sugary adflow adstock tmax tmin rain size size288 size330 size380 size500 coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside nonoutside inv
order dmindex csindex hhno indvno sugar_prev order indrink group date day week month year date tm rm product prodagg brand firm inside choice price price_smooth drinks sugary adflow adstock tmax tmin rain size size288 size330 size380 size500 coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside nonoutside inv

su
table product,c(mean price mean size mean drinks mean sugary)

sa "$P/Estimation_data.dta",replace
