clear
cap log close
set more off

global P    "$cd"
global Prog "$pg"

**************************************************************************
**A) Construct product attributes
**************************************************************************

u "M:\TNS\extractedfiles\purchase_data\Derived_data_by_rfy/RF84_2009.dta",clear
forv y = 2009(1)2014 {
	append using "M:\TNS\extractedfiles\purchase_data\Derived_data_by_rfy/RF84_`y'.dta"
}	

foreach n of numlist 647 648 656 657 658 659 1179 1342 1343 1344 {
	forv y = 2009(1)2014 {
		append using "M:\TNS\extractedfiles\purchase_data\Derived_data_by_rfy/RF`n'_`y'.dta"
	}
}
drop if date<20090601
drop if date>20141228
sa "$P/FoodIn/rawdata.dta",replace

keep prodcode rf

sa "$P/FoodIn/allprodcodes.dta",replace

u "M:\TNS\extractedfiles\product_attributes\RF84.dta",clear

append using "M:\TNS\extractedfiles\product_attributes\RF647.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF648.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF656.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF657.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF658.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF659.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF1179.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF1342.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF1343.dta"
append using "M:\TNS\extractedfiles\product_attributes\RF1344.dta"

bysort prodcode: keep if _n==1
merge 1:m prodcode using "$P\FoodIn/allprodcodes.dta"
keep if _m==3
drop _m

bysort brand: drop if _N<10000
bysort productdesc: drop if _N<2000

rename brand brand_old

gen diet = index(brand_old,"Diet")>0|index(brand_old,"Zero")>0|index(brand_old,"Light")>0|index(brand_old,"Mx")>0|index(brand_old,"Max")>0|index(brand_old,"Lite")>0|index(brand_old,"Free")>0|index(brand_old,"Lght")>0|index(brand_old,"Dt")>0|index(brand_old,"NAS")>0|index(brand_old,"Beach")
gen multi = sizegroup=="Multi-Pack"

gen     brand = 1 if index(brand_old,"Coca Cola")>0|index(brand_old,"Diet Coke")>0|index(brand_old,"Cffn/Fr Dt Coke")>0
replace brand = 2 if index(brand_old,"Dr. P")>0|index(brand_old,"Dr.P")>0
replace brand = 3 if index(brand_old,"Fanta")>0
replace brand = 4 if index(brand_old,"Cherry Coke")>0
replace brand = 5 if index(brand_old,"Oasis")>0
replace brand = 6 if (index(brand_old,"Pepsi")>0)
replace brand = 7 if (index(brand_old,"Luco")>0)& index(brand_old,"Sport")==0&index(brand_old,"Sprt")==0
replace brand = 8 if index(brand_old,"Ribena")>0
replace brand = 9  if index(brand_old,"Sprite")>0
replace brand = 10 if index(brand_old,"Irn Bru")>0

replace brand = 101 if brand==. & (rf==647|rf==648|rf==656|rf==657|rf==658|rf==659) & (index(brand_old,"Asda")>0|index(brand_old,"Lidl")>0|index(brand_old,"Mrrns")>0|index(brand_old,"Sains")>0|index(brand_old,"Tesco")>0|index(brand_old,"Vive")>0|index(brand_old,"Freeway")>0)
replace brand = 100 if brand==. & (rf==647|rf==648|rf==656|rf==657|rf==658|rf==659)

replace brand = 110 if rf==1179 & brand==.
replace brand = 120 if rf==1343 & brand==.
replace brand = 130 if rf==84 & index(lower(brand_old),"frt")>0
replace brand = 140 if rf==84 & brand==.

lab def brand 1 "Coke" 2 "Dr Pepper" 3 "Fanta" 4 "Cherry Coke" 5 "Oasis" 6 "Pepsi" 7 "Lucozade Energy" 8 "Ribena" 9 "Sprite" 10 "Irn Bru" 100 "Other" 101 "Store" 110 "Fruit juice" 120 "Flavoured milk" 130 "Fruit water" 140 "Water"
lab val brand brand

replace diet = 1 if brand==140

gen     firm = 1 if manufacturer=="Coca Cola Bottlers"| manufacturer=="Coca Cola Enterprises"
replace firm = 2 if manufacturer=="Britvic / Pepsico"
replace firm = 3 if manufacturer=="Lucozade Ribena Suntory"
replace firm = 4 if manufacturer=="A.G.Barr Plc"
replace firm = 100 if brand>=100

lab def firm 1 "CocaCola" 2 "Pepsico" 3 "GSK"  100 "Outside"
lab val firm firm

**Product: Coke
gen     product = 1  if brand==1  & size=="330 Ml" & diet==0
replace product = 2  if brand==1  & size=="500 Ml" & diet==0
replace product = 3  if brand==1  & size=="330 Ml" & diet==1
replace product = 4  if brand==1  & size=="500 Ml" & diet==1

replace product = 1011 if brand==1 & product==. & packtype=="Cans"           & multi==1 & diet==0
replace product = 1012 if brand==1 & product==. & packtype=="Cans"           & multi==1 & diet==1
replace product = 1013 if brand==1 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==0
replace product = 1014 if brand==1 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==1 & size!="375 Ml" 
replace product = 1015 if brand==1 & product==. & packtype=="Plastic Bottle" & multi==1 & diet==0 
replace product = 1016 if brand==1 & product==. & packtype=="Plastic Bottle" & multi==1 & diet==1 

foreach n of numlist 1 2 3 4 1011 1012 1013 1014 1015 1016 {
	tab productdesc if product==`n'
}

tab productdesc if product==. & brand==1

**Product: Dr Pepper
replace product = 5  if brand==2  & size=="330 Ml" & diet==0
replace product = 6  if brand==2  & size=="500 Ml" & diet==0

replace product = 1021 if brand==2 & product==. & packtype=="Cans"           & multi==1 & diet==0
replace product = 1022 if brand==2 & product==. & packtype=="Cans"           & multi==1 & diet==1
replace product = 1023 if brand==2 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==0
replace product = 1024 if brand==2 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==1

foreach n of numlist 5 6 1021 1022 1023 1024  {
	tab productdesc if product==`n'
}

tab productdesc if product==. & brand==2

**Product: Fanta
replace product = 9 if brand==3  & size=="500 Ml" & diet==0

replace product = 1031 if brand==3 & product==. & packtype=="Cans"           & multi==1 & diet==0
replace product = 1032 if brand==3 & product==. & packtype=="Cans"           & multi==1 & diet==1
replace product = 1033 if brand==3 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==0
replace product = 1034 if brand==3 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==1

foreach n of numlist 9 1031 1032 1033 1034  {
	tab productdesc if product==`n'
}

tab productdesc if product==. & brand==3

**Product: Cherry Coke
replace product = 11 if brand==4  & size=="330 Ml" & diet==0
replace product = 12 if brand==4  & size=="500 Ml" & diet==0
replace product = 13 if brand==4  & size=="500 Ml" & diet==1

replace product = 1041 if brand==4 & product==. & packtype=="Cans"           & multi==1 & diet==0
replace product = 1042 if brand==4 & product==. & packtype=="Cans"           & multi==1 & diet==1
replace product = 1043 if brand==4 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==0
replace product = 1044 if brand==4 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==1

foreach n of numlist 11 12 13 1041 1042 1043 1044  {
	tab productdesc if product==`n'
}

tab productdesc if product==. & brand==4

**Product: Oasis
replace product = 14 if brand==5 & size=="500 Ml" & diet==0

tab productdesc if product==14

tab productdesc if brand==5 & product==.

**Product: Pepsi
replace product = 16 if brand==6  & size=="330 Ml" & diet==0
replace product = 17 if brand==6  & (size=="500 Ml"|size=="600 Ml") & diet==0
replace product = 18 if brand==6  & size=="330 Ml" & diet==1
replace product = 19 if brand==6  & (size=="500 Ml"|size=="600 Ml") & diet==1

replace product = 1061 if brand==6 & product==. & packtype=="Cans"           & multi==1 & diet==0
replace product = 1062 if brand==6 & product==. & packtype=="Cans"           & multi==1 & diet==1
replace product = 1063 if brand==6 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==0
replace product = 1064 if brand==6 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==1

foreach n of numlist 16 17 18 19 1061 1062 1063 1064  {
	tab productdesc if product==`n'
}

tab productdesc if product==. & brand==6

**Product: Lucozade
replace product = 20 if brand==7 & size=="380 Ml" & diet==0
replace product = 21 if brand==7 & size=="500 Ml" & diet==0

replace product = 1071 if brand==7 & product==. & multi==0 
replace product = 1072 if brand==7 & product==. & multi==1 

foreach n of numlist 20 21 1071 1071 {
	tab productdesc if product==`n'
}

tab productdesc if product==. & brand==7

**Product: Ribena
replace product = 22 if brand==8  & size=="288 Ml" & diet==0
replace product = 23 if brand==8  & size=="500 Ml" & diet==0

replace product = 1081 if brand==8 & product==. & multi==1

foreach n of numlist 22 23 1081 {
	tab productdesc if product==`n'
}
tab productdesc if brand==8 & product==.

**Product: Sprite
replace product = 26 if brand==9 & size=="500 Ml" & diet==0

replace product = 1091 if brand==9 & product==. & packtype=="Cans"           & multi==1 & diet==0
replace product = 1092 if brand==9 & product==. & packtype=="Cans"           & multi==1 & diet==1
replace product = 1093 if brand==9 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==0
replace product = 1094 if brand==9 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==1

foreach n of numlist 26 1091 1092 1093 1094 {
	tab productdesc if product==`n'
}
tab productdesc if brand==9 & product==.

**Product: Irn Bru
replace product = 28 if brand==10 & size=="500 Ml" & diet==0
replace product = 30 if brand==10 & size=="500 Ml" & diet==1

replace product = 1101 if brand==10 & product==. & packtype=="Cans"           & multi==1 & diet==0
replace product = 1102 if brand==10 & product==. & packtype=="Cans"           & multi==1 & diet==1
replace product = 1103 if brand==10 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==0 & size!="250 Ml"
replace product = 1104 if brand==10 & product==. & packtype=="Plastic Bottle" & multi==0 & diet==1 & size!="250 Ml"

foreach n of numlist 28 30 1101 1102 1103 1104 {
	tab productdesc if product==`n'
}
tab productdesc if brand==10 & product==.


**Other brands
replace product = 31 if brand==100 & (size=="150 Ml"|size=="250 Ml"|size=="330 Ml"|size=="500 Ml"|size=="750 Ml") & diet==0
replace product = 32 if brand==100 & (size=="150 Ml"|size=="250 Ml"|size=="330 Ml"|size=="500 Ml"|size=="750 Ml") & diet==1

replace product = 11001 if brand==100 & product==. & multi==0 & diet==0
replace product = 11002 if brand==100 & product==. & multi==0 & diet==1
replace product = 11003 if brand==100 & product==. & multi==1 & diet==0
replace product = 11004 if brand==100 & product==. & multi==1 & diet==1

foreach n of numlist 31 32 11001 11002 11003 11004 {
	tab productdesc if product==`n'
}

tab productdesc if product==. & brand==100

**Store brands

replace product = 11015 if brand==101 & product==. & diet==0 
replace product = 11016 if brand==101 & product==. & diet==1 

foreach n of numlist 11015 11016 {
	tab productdesc if product==`n'
}

replace product = 110   if brand==110 & (size=="750 Ml"|size=="900 ML")
replace product = 99110 if brand==110 & product==.
replace product = 120   if brand==120 & size!="1 Lt"
replace product = 99120 if brand==120 & product==.
replace product = 130   if brand==130 & size=="500 Ml"
replace product = 99130 if brand==130 & product==.
replace product = 140   if brand==140 & (size=="330 Ml"|size=="500 Ml"|size=="750 Ml")
replace product = 99140 if brand==140 & product==.

drop if product==.

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

gen bottle = packtype=="Plastic Bottle"
replace bottle = 0 if brand>=100

keep prodcode productdesc manufacturer brand_old rf brand diet multi bottle size firm product 
tab brand
tab product

sa "$P\FoodIn/prodcode_purchases.dta",replace

bysort prodcode: keep if _n==1

gen     prodagg = 1  if product==1|product==3
replace prodagg = 2  if product==2|product==4
replace prodagg = 3  if product==5
replace prodagg = 4  if product==6
replace prodagg = 5  if product==9
replace prodagg = 6  if product==11
replace prodagg = 7  if product==12|product==13
replace prodagg = 8  if product==14
replace prodagg = 9  if product==16|product==18
replace prodagg = 10 if product==17|product==19
replace prodagg = 11 if product==20
replace prodagg = 12 if product==21
replace prodagg = 13 if product==22
replace prodagg = 14 if product==23
replace prodagg = 15 if product==26
replace prodagg = 16 if product==28|product==30
replace prodagg = 17 if product==31
replace prodagg = 18 if product==110
replace prodagg = 19 if product==120
replace prodagg = 20 if product==130
replace prodagg = 21 if product==140
replace prodagg = 22 if product==1011
replace prodagg = 23 if product==1012
replace prodagg = 24 if product==1013
replace prodagg = 25 if product==1014
replace prodagg = 26 if product==1015
replace prodagg = 27 if product==1016
replace prodagg = 28 if product==1021
replace prodagg = 29 if product==1022
replace prodagg = 30 if product==1023
replace prodagg = 31 if product==1024
replace prodagg = 32 if product==1031
replace prodagg = 33 if product==1032
replace prodagg = 34 if product==1033
replace prodagg = 35 if product==1034
replace prodagg = 36 if product==1041
replace prodagg = 37 if product==1042
replace prodagg = 38 if product==1043
replace prodagg = 39 if product==1044
replace prodagg = 40 if product==1061
replace prodagg = 41 if product==1062
replace prodagg = 42 if product==1063
replace prodagg = 43 if product==1064
replace prodagg = 44 if product==1071
replace prodagg = 45 if product==1072
replace prodagg = 46 if product==1081
replace prodagg = 47 if product==1091
replace prodagg = 48 if product==1092
replace prodagg = 49 if product==1093
replace prodagg = 50 if product==1094
replace prodagg = 51 if product==1101
replace prodagg = 52 if product==1102
replace prodagg = 53 if product==1103
replace prodagg = 54 if product==1104 
replace prodagg = 55 if product==11001
replace prodagg = 56 if product==11002
replace prodagg = 57 if product==11003
replace prodagg = 58 if product==11004
replace prodagg = 59 if product==11015
replace prodagg = 60 if product==11016
replace prodagg = 61 if product==99110
replace prodagg = 62 if product==99120
replace prodagg = 63 if product==99130
replace prodagg = 64 if product==99140
               				  
#delimit ;
lab def prodagg 
1  "Coca Cola 330" 2  "Coca Cola 500"
3  "Dr Pepper 330" 4  "Dr Pepper 500" 
5  "Fanta 500" 
6  "Cherry Coke 330" 7 "Cherry Coke 500"
8 "Oasis 500"
9 "Pepsi 330" 10 "Pepsi 500"  
11 "Lucozade Energy 380" 12 "Lucozade Energy 500" 
13 "Ribena 288" 14 "Ribena 500" 
15 "Sprite 500"
16 "Irn Bru 500"
17 "Other" 
18 "Fruit juice" 19 "Flavoured milk" 20 "Fruit water" 21 "Water"
22 "Coca Cola multi can" 23 "Coca Cola Diet multi can" 24 "Coca Cola bottle"
25 "Coca Cola Diet bottle" 26 "Coca Cola multi bottle" 27 "Coca Cola Diet multi bottle"
28 "Dr Pepper multi can" 29 "Dr Pepper Diet multi can" 
30 "Dr Pepper bottle" 31 "Dr Pepper Diet bottle"
32 "Fanta multi can" 33 "Fanta Diet multi can" 
34 "Fanta bottle" 35 "Fanta Diet bottle"
36 "Cherry Coke multi can" 37 "Cherry Coke Diet multi can" 
38 "Cherry Coke bottle" 39 "Cherry Coke Diet bottle"
40 "Pepsi multi can" 41 "Pepsi Diet multi can"
42 "Pepsi bottle" 43 "Pepsi Diet bottle"
44 "Lucozade Energy bottle" 45 "Lucozade Energy multi bottle"
46 "Ribena multi"
47 "Sprite multi can" 48 "Sprite Diet multi can"
49 "Sprite bottle" 50 "Sprite Diet bottle"
51 "Irn Bru multi can" 52 "Irn Bru Diet multi can"
53 "Irn Bru bottle" 54 "Irn Bru Diet bottle"
55 "Other bg" 56 "Other Diet bg" 57 "Other multi" 58 "Other Diet multi"
59 "Store" 60 "Store Diet"
61 "Fruit juice bg" 62 "Flavoured milk bg" 63 "Fruit water bg" 64 "Water bg";				  
#delimit cr
lab val prodagg prodagg

decode brand,gen(brandstr)
replace brand_o = "7up" if index(brand_o,"7 U")>0
replace brand_o = "Schwps" if index(brand_o,"Schwps")>0
replace brand_o = "Vimto" if index(brand_o,"Vimto")>0
replace brandstr = brand_o if brand>10

keep prodcode brand diet multi bottle size firm product prodagg brandstr

sa "$P/FoodIn\attributes.dta",replace

**************************************************************************
**B) Sample of households
**************************************************************************

u "$P/indvno_sample.dta",clear

collapse (min) entry (max) exit,by(hhno)

sa "$P/FoodIn/hhno_sample.dta",replace

u "M:\TNS\extractedfiles\panel_data\hhpanel_all.dta",clear

merge m:1 hhno using "$P/FoodIn/hhno_sample.dta"
drop if _m==1
drop _m

keep if demyear>2008 & demyear<2015

rename msage age
rename mssex sex

gen nkids0_9=0
gen nkids10_13=0
gen nkids14_17=0
gen n1864=0
gen n65plus=0
foreach n of numlist 1(1)12 {
   replace nkids0_9=nkids0_9+1 if ageper`n'<=9
   replace nkids10_13=nkids10_13+1 if ageper`n'>=10&ageper`n'<=13
   replace nkids14_17=nkids14_17+1 if ageper`n'>=14&ageper`n'<=17
   replace n1864=n1864+1 if ageper`n'>=18&ageper`n'<65
   replace n65plus=n65plus+1 if ageper`n'>=65 & ageper`n'!=.
}

drop if ageper1<18  | ageper1==.
gen nkids=nkids0_9+nkids10_13+nkids14_17
gen nads=n1864+n65plus

gen     fz=1 if n1864==1 & n65plus==0 & nkids==0
replace fz=2 if n1864==0 & n65plus==1 & nkids==0
replace fz=3 if nads==2 & nkids==0
replace fz=4 if nads==2 & n65plus>0 & nkids==0
replace fz=5 if nads>2 & nkids==0

replace fz=6 if nads==1 & nkids>0
replace fz=7 if nads>=2 & nkids>0 & nkids0_9>0
replace fz=8 if nads>=2 & nkids>0 & nkids0_9==0

lab def fz 1 "Single young" 2 "Single pensioner" 3 "Couple no child" 4 "Couple pensioner" 5 "Multi adult" 6 "Single parent" 7 "Young child (0-9)" 8 "Old child (10+)"
lab val fz fz
tab famtype fz
tab fz,miss

gen hicl = class<3

**No kids no pensioners; high social class
gen     hhtype = 1 if (fz==1|fz==3|fz==5) & hicl==1
**No kids no pensioners; low social class
replace hhtype = 2 if (fz==1|fz==3|fz==5) & hicl==0
**Pensioners
replace hhtype = 3 if fz==2|fz==4
**Households with kids; high social class
replace hhtype = 4 if (fz==6|fz==7|fz==8) & hicl==1
**Households with kids; low social class
replace hhtype = 5 if (fz==6|fz==7|fz==8) & hicl==0

keep hhno hhtype
bysort hhno hhtype: gen N = -_N
bysort hhno N: keep if _n==1
drop N

set seed 246
drawnorm x
sort hhno x
by hhno: keep if _n==1
drop x

cap lab def hhtype 1 "No kids; high class"  2 "No kids; low class" 3 "Pensioners" 4 "Kids; high class" 5 "Kids; low class"
lab val hhtype hhtype

sa "$P/FoodIn/hh_type.dta",replace


**************************************************************************
**C) Drinks purchases
**************************************************************************

u "M:/TNS/extractedfiles/fotg_data/age_sex_full.dta",clear

collapse (max) regdis,by(hhno)

sa "$P/FoodIn/hhno_reg.dta",replace

u "$P/FoodIn/rawdata.dta",clear

drop if exp==0|vol==0
centile volume,centile(1 99)
centile npacks,centile(95)
drop if npacks>=r(c_1)
drop size

merge m:1 date using "$P\week.dta"
drop if _m==2
drop _m

merge m:1 prodcode using "$P\FoodIn\attributes.dta"
keep if _m==3
drop _m

egen gp = group(prodagg brandstr size)
gen p=exp/npacks
gen drop = 0
su gp
local l = r(max)
forv n=1/`l' {
	centile p if gp==`n',centile(1 99)
	replace drop = 1 if (p<r(c_1)|p>r(c_2)) & gp==`n'
}	
drop if drop==1
drop gp p drop

merge m:1 shopcode using "M:\TNS\extractedfiles\fotg_data\shopcodes.dta"
drop if _m==2
drop _m

drop if fascia==""

gen     storetype = 1 if index(lower(fascia),"asda")>0
replace storetype = 2 if index(lower(fascia),"morrisons")>0
replace storetype = 3 if index(lower(fascia),"sainsbury")>0
replace storetype = 4 if index(lower(fascia),"tesco")>0
replace storetype = 5 if index(lower(fascia),"aldi")>0|index(lower(fascia),"lidl")>0
replace storetype = 6 if storetype==.

forv s=1/6 {
	tab fascia if storetype==`s'
}

lab def st 1 "Asda" 2 "Morrisons" 3 "Sainsburys" 4 "Tesco" 5 "Discounters" 6 "Other"
lab val storetype st

sa "$P/FoodIn/drinkpurchases_raw_allhh.dta",replace

merge m:1 hhno using "$P/FoodIn/hhno_sample.dta"
keep if _m==3
drop if day<entry | day>exit
drop _m entry exit 

merge m:1 hhno using "$P/FoodIn/hhno_reg.dta",keepusing(regdis)
keep if _m==3
drop _m

egen tm = group(year month)
rename storetype rm

sa "$P/FoodIn/drinkpurchases_raw.dta",replace


u "$P/FoodIn/drinkpurchases_raw_allhh.dta",clear

gen i = 1

replace size = "x" if product<31

collapse (sum) i,by(prodagg brandstr storetype size year)

egen gp = group(prodagg brandstr size)

fillin gp storetype year
replace i = 0 if _f==1
drop _f

forv n=1/40 {
	by gp: replace prodagg=prodagg[_n+1] if prodagg==.
	by gp: replace prodagg=prodagg[_n-1] if prodagg==.
	by gp: replace size=size[_n+1] if size==""
	by gp: replace size=size[_n-1] if size==""
	by gp: replace brandstr=brandstr[_n+1] if brandstr==""
	by gp: replace brandstr=brandstr[_n-1] if brandstr==""
}	
drop gp 

gen notavail = i<100

egen sum = sum(i),by(notavail)
table notavail,c(mean sum)
tab notavail
drop sum

sa "$P/FoodIn/rmprodsizeyear_avail.dta",replace

u "$P/FoodIn/rmprodsizeyear_avail.dta",clear

collapse (min) notavail,by(prodagg brandstr storetype size)

sa "$P/FoodIn/rmprodsize_avail.dta",replace

u "$P/FoodIn/rmprodsizeyear_avail.dta",clear

collapse (min) notavail,by(prodagg storetype year)

sa "$P/FoodIn/rmproduct_avail.dta",replace


u "$P/FoodIn/drinkpurchases_raw.dta",clear

merge m:1 hhno year month using "M:/TNS/extractedfiles/index_files/sample_hhyrmonth.dta",keepusing(sample_14day)
drop if _m==2
keep if sample_14day==1
drop _m sample_14day

gen storetype = rm
replace size = "x" if product<31
merge m:1 prodagg storetype size brandstr year using "$P/FoodIn/rmprodsizeyear_avail.dta"
drop if _m==2
keep if notavail==0
drop notavail _m storetype

bysort hhno day: gen n = _n
egen N = sum(n),by(hhno)
keep if N>14
drop n N

gen soda = product!=110&product!=120&product!=130&product!=140&product!=99110&product!=99120&product!=99130&product!=99140

bysort hhno day soda: gen n = _n
replace n = . if soda==0
egen N = sum(n),by(hhno)
keep if N>9
drop n N

bysort hhno date product multi rm: keep if _n==1
merge 1:1 hhno date product multi rm using "M:/TNS/extractedfiles/index_files/index.dta"
keep if _m==3
drop _m

/*
set seed 27
drawnorm x
sort hhno date x
by hhno date: gen temp=_n
keep if temp==1
drop x temp
*/
bysort hhno product: gen f = 1 if _n==1
egen sum = sum(f),by(hhno)
drop if sum==1
drop sum f

keep hhno date date month year week day tm regdis rm product prodagg diet multi bottle size brand firm soda

merge m:1 hhno week using "M:/TNS/extractedfiles/index_files/trips.dta"
gen inside = _m==3
egen sumi = sum(inside),by(hhno)
drop if sumi==0
drop _m sumi

replace product = 99999 if product==.
replace prodagg = 99999 if prodagg==.
replace brand   = 99999 if brand==.
replace firm    = 99999 if firm==.

foreach v in diet multi bottle soda {
	replace `v' = 0 if product==99999
}

egen temp = min(tm),by(year month)
replace tm = temp if tm==.
drop temp

egen temp = min(regdis),by(hhno)
replace regdis = temp if regdis==.
drop temp

egen dmindex = group(hhno)
egen csindex = group(hhno date)

gen sugary = 1-diet
replace sugary = 0 if product==140|product==99140|product==99999

gen drink   = brand<199
gen outside = brand>=199

egen sum_drink   = sum(drink),by(hhno)
egen sum_outside = sum(outside),by(hhno)

gen indrink = sum_drink>10 & sum_outside>10

drop drink outside sum_*

gen temp = sugary if product!=99999
egen mean_s = mean(temp),by(hhno)
gen     sugar_prev = 1 if mean_s==1
replace sugar_prev = 2 if mean_s==0
replace sugar_prev = 3 if mean_s!=0&mean_s!=1&mean_s!=. 
lab def fin 1 "All" 2 "None" 3 "Switch"
lab val sugar_prev fin

bysort hhno: gen n = _n
drop temp mean_s

gen     order = 1 if sugar_prev==3
replace order = 2 if sugar_prev==2
replace order = 3 if sugar_prev==1

lab def order 1 "Switch" 2 "None" 3 "All" 
lab val order order

tab order if n==1
tab order indrink if n==1
drop n

order dmindex csindex

label var dmindex            "Decision maker index"
label var csindex            "Choice situation index"
label var hhno               "Index of hh"

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
label var size				 "Size"
label var multi				 "Multi-pack"
label var bottle			 "Bottle"
label var soda				 "Soft drink product"
label var tm                 "Time market"
label var rm                 "Store/region market"

sa "$P/FoodIn/all_purchases.dta",replace

**************************************************************************
**D) Create price for each product
**************************************************************************

**Weights 
u "$P/FoodIn/drinkpurchases_raw_allhh.dta",clear

replace size = "x" if product<31
merge m:1 prodagg storetype brandstr size using "$P/FoodIn/rmprodsize_avail.dta"
drop if _m==2
drop if notavail==1
drop notavail _m 

gen i = 1

collapse (sum) i,by(prodagg storetype brandstr size)

egen tot = sum(i),by(prodagg storetype)

gen weight = i/tot

drop i tot

sa "$P/FoodIn/priceweights.dta",replace

u "$P/FoodIn/drinkpurchases_raw_allhh.dta",clear

replace size = "x" if product<31
merge m:1 prodagg storetype brandstr size using "$P/FoodIn/rmprodsize_avail.dta"
keep if _m==3
keep if notavail==0
drop notavail _m

gen psize = volume/npack

collapse (mean) psize,by(prodagg)

rename psize meansize

sa "$P/FoodIn/meansize.dta",replace

u "$P/FoodIn/drinkpurchases_raw_allhh.dta",clear

replace size = "x" if product<31
merge m:1 prodagg storetype brandstr size using "$P/FoodIn/rmprodsize_avail.dta"
drop if _m==2
keep if notavail==0
drop notavail _m

egen prrm=group(prodagg brandstr size storetype)

bysort prrm: keep if _n==1

keep prrm prodagg brandstr size storetype

sa "$P/FoodIn/prrmmapping.dta",replace

u "$P/FoodIn/drinkpurchases_raw_allhh.dta",clear

replace size = "x" if product<31
merge m:1 prodagg storetype brandstr size using "$P/FoodIn/rmprodsize_avail.dta"
drop if _m==2
drop if notavail==1
drop notavail _m 

merge m:1 prodagg brandstr size storetype using "$P/FoodIn/prrmmapping.dta"
drop if _m==2
drop _m

gen psize = volume/npack
gen price = expenditure/npack

egen tm = group(year month)

bysort prodagg tm brandstr size storetype: gen N = _N

collapse (mean) price N psize,by(prrm tm year month)

fillin prrm tm 
tab _f

merge m:1 prrm using "$P/FoodIn/prrmmapping.dta"
drop _m

merge m:1 prodagg storetype brandstr size using "$P/FoodIn/priceweights.dta"
keep if _m==3
drop _m

foreach v in year month {
	egen temp = min(`v'),by(tm)
	replace `v' = temp if `v'==.
	drop temp
}

egen temp = min(psize),by(prrm)
replace psize = temp if psize==.
drop temp

replace N = 0 if N==.

gen pricetemp = price if N>3
ipolate pricetemp tm,by(prodagg brandstr psize storetype) gen(prc)

sort prodagg brandstr psize storetype tm
forval l=1/73 {
	by prodagg brandstr psize storetype: replace prc = prc[_n+1] if prc==.
	by prodagg brandstr psize storetype: replace prc = prc[_n-1] if prc==.
}

drop price pricetemp
rename prc price

merge m:1 prodagg storetype brandstr size year using "$P/FoodIn/rmprodsizeyear_avail.dta"
keep if notavail==0
drop notavail _m

egen sum = sum(weight),by(prodagg storetype tm)

replace price = price*(weight/sum)
replace psize = psize*(weight/sum)

collapse (sum) price psize,by(prodagg storetype tm year)

replace price = price*(.5/psize) if prodagg==10
replace psize = .5               if prodagg==10

merge m:1 prodagg using "$P/FoodIn/meansize.dta"
drop _m

replace price = price*(meansize/psize) if prodagg>16
replace psize = meansize               if prodagg>16

rename storetype rm

keep  year tm rm prodagg price psize
order year tm rm prodagg price psize

sa "$P/FoodIn/prices.dta",replace


**************************************************************************
**E) Create advertising and weather variables
**************************************************************************

do "$Prog/8.c.i.foodinweather.do"

**************************************************************************
**F) Create data for estimation
**************************************************************************

u "$P/FoodIn/all_purchases.dta",clear

keep dmindex csindex hhno date year month week day rm regdis tm sugar_prev order indrink

sa "$P/FoodIn/index_vars.dta",replace

u "$P/FoodIn/all_purchases.dta",clear

bysort product: keep if _n==1
keep diet multi brand firm product bottle prodagg soda inside sugary

sa "$P/FoodIn/options_vars.dta",replace
*/
u "$P/FoodIn/all_purchases.dta",clear

keep csindex product
gen choice = 1
fillin csindex product
drop _fillin
replace choice=0 if choice==.

mer m:1 csindex using "$P/FoodIn/index_vars.dta"
keep if _m==3
drop _m

merge m:1 product using "$P/FoodIn/options_vars.dta"
keep if _m==3
drop _m

merge m:1 hhno day using "$P/athome_inventories.dta",keepusing(invssoft invdsoft invfruit invfmilk invfwater invwater)
drop if _m==2
drop _m

gen     inv = invssoft  if soda==1 & diet==0
replace inv = invdsoft  if soda==1 & diet==1
replace inv = invfruit  if product==110|product==99110
replace inv = invfmilk  if product==120|product==99120
replace inv = invfwater if product==130|product==99130
replace inv = invwater  if product==140|product==99140
replace inv = 0         if product==999999
replace inv = 0         if inv==.
drop invssoft invdsoft invfruit invfmilk invfwater invwater

****************
**Create choice sets
****************

gen storetype = rm
merge m:1 prodagg storetype year using "$P/FoodIn/rmproduct_avail.dta"
keep if notavail==0|product==99999
drop notavail _m storetype

drop if sugary==0 & sugar_prev==1 & product!=99999
drop if sugary==1 & sugar_prev==2 

mer m:1 prodagg tm rm using "$P/FoodIn/prices.dta"
foreach v in price psize {
	replace `v' = 0 if product==99999
}
drop _m

**merge m:1 hhno using "$P/FoodIn/hh_type.dta"
merge m:1 hhno using "P:\Nutrition\Soda_DGO\DuboisGriffithOConnell2020/Data/CreateData/FoodIn/hh_type.dta"
keep if _m==3
drop _m


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
gen store        = brand==101
gen fruit        = brand==110
gen milk         = brand==120
gen fruitwater   = brand==130
gen water        = brand==140
gen outside      = brand==99999

gen drinks = brand!=99999

gen size288 = psize>.28&psize<.29
gen size330 = psize>.32&psize<.34
gen size380 = psize>.37&psize<.39
gen size500 = psize>.48&psize<.505

gen size1 = psize>0.5 & psize<1 
gen size2 = psize==1 
gen size3 = psize>1   & psize<=1.5
gen size4 = psize>1.5 & psize<=2
gen size5 = psize>2   & psize<=2.5
gen size6 = psize>2.5 & psize<=3
gen size7 = psize>3   & psize<=4
gen size8 = psize>4

merge m:1 regdis brand week using "$P/addata.dta"
drop if _m==2
tab brand if _m==1
replace adflow = 0  if adflow==.
replace adstock = 0 if adstock==.
drop _m

merge m:1 hhno year month using "$P/FoodIn/hhym_weather_string_in.dta"
drop if _m==2
drop _m

label var dmindex            "Decision maker index"
label var csindex            "Choice situation index"
label var hhno               "Index of hh"
label var sugar_prev         "Sugar switchers"

label var order              "Switcher indicator"
label var indrink   		 "Include drinks effect"
label var hhtype     		 "Demographic group"

label var date               "Date"
label var day                "Day"
label var week               "Week"
label var month              "Month"
label var year               "Year"
label var date               "Date"

label var tm                 "Time market"
label var rm                 "Store/region market"

label var product            "Product"
label var prodagg			 "Product agg for prices"	
label var brand              "Brand"
label var firm               "Firm"
label var inside             "Inside option"

label var choice             "1 for option chosen"
label var price              "Option price"
label var drinks             "Drinks dummy"
label var sugary             "Nondiet dummy"

label var adflow			 "Weekly adv (£100,000)"	
label var adstock			 "Adv stock (£100,000)"	
label var tmax				 "Monthly max temp"
label var tmin               "Monthly min temp"  
label var rain               "Monthly rainfail"

label var psize               "Option size"
label var size288            "Size dummy"
label var size330            "Size dummy"
label var size380            "Size dummy"
label var size500            "Size dummy"
label var size1              "0.5l-1l"
label var size2              "1l"
label var size3 			 "1l-1.5l"
label var size4              "1.5l-2l"
label var size5              "2l-2.5l"
label var size6              "2.5l-3l"
label var size7              "3-4l"
label var size8              "4+l" 

label var multi			     "Multi pack"
label var bottle			 "Bottle"

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
label var store              "Brand dummy"
label var fruit              "Brand dummy"
label var milk               "Brand dummy"
label var fruitwater         "Brand dummy"
label var water              "Brand dummy"
label var outside			 "Outside option dummy"
 
label var inv				 "At home inventory"

keep  dmindex csindex hhno sugar_prev order indrink hhtype date day week month year date tm rm product prodagg brand firm inside choice price drinks sugary adflow adstock tmax tmin rain psize size288 size330 size380 size500 size1-size8 multi bottle coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater water outside inv
order dmindex csindex hhno sugar_prev order indrink hhtype date day week month year date tm rm product prodagg brand firm inside choice price drinks sugary adflow adstock tmax tmin rain psize size288 size330 size380 size500 size1-size8 multi bottle coke drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other store fruit milk fruitwater water outside inv

su
table product,c(mean price mean psize mean drinks mean sugary)

sa "$P/FoodIn/Estimation_data.dta",replace

u "$P/FoodIn/Estimation_data.dta",clear

gen temp = 1 if choice==1 & product<1000
egen cs1 = max(temp),by(csindex)
replace cs1=0 if cs1==.

drop if (product>1000&product!=99999) & cs1==1
drop if  product<1000 & cs1==0

tab product choice if cs1==1
tab product choice if cs1==0

drop cs1 temp
bysort csindex: gen N = _N
drop if N==1
drop N

sa "$P/FoodIn/Estimation_data_cs.dta",replace
