clear all
cap log close
set more off

global P "$ds"

u "M:\TNS\extractedfiles\drinks\OOH\purchase.dta",clear

drop date 
gen double date  = year*10000 + month*100 + dayofmonth

merge m:1 prodcode using "M:\TNS\extractedfiles\drinks\OOH\ProductAttributes\rf1631.dta",keepusing(productdesc brand totalfotgsector manufacturer)
keep if _m==3
drop _m

gen diet = index(brand,"Diet")>0|index(brand,"Zero")>0|index(brand,"Light")>0|index(brand,"Mx")>0|index(brand,"Max")>0|index(brand,"Lite")>0|index(brand,"Free")>0|index(brand,"Lght")>0|index(brand,"Dt")>0|index(brand,"NAS")>0|index(brand,"Beach")

rename brand brand_old

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

gen pd_temp = lower(word(productdesc,-1))
gen pack = .
forval x=8(-1)3 {
   replace pack = real(substr(pd_temp,-`x',`x'-2)) if pack==. & strpos(pd_temp,"-")==0&real(substr(pd_temp,-2,1))==.
}
forval x=8(-1)2 {
   replace pack = real(substr(pd_temp,-`x',`x'-1)) if pack==. & strpos(pd_temp,"-")==0&real(substr(pd_temp,-2,1))!=.
}
drop if pack<200


**Firm: CocaCola
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

**Firm: Pepsico
**Product: Pepsi
replace product = 19 if brand==6  & pack==330             & diet==0
replace product = 20 if brand==6  & (pack==500|pack==600) & diet==0
replace product = 21 if brand==6  & pack==330             & diet==1
replace product = 22 if brand==6  & (pack==500|pack==600) & diet==1

forval n =19/22 {
	tab productdesc if product==`n'
}
tab productdesc if brand==6 & product==.

**Firm: GSK
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

drop if product==.
drop if brand>30

gen price = exp/(npack*pack/1000)
centile price,centile(1 99)
drop if price<r(c_1)|price>r(c_2)

gen hitreat = (brand==1|brand==4|brand==6)&diet==0

tab product,gen(pp)

egen group = group(year month)
tab group,gen(gp)
gen afternontr = (date>20180399)*(1-hitreat)
gen aftertreat = (date>20180399)*hitreat

merge m:1 shopcode using "M:/TNS/extractedfiles/fotg_data/shopcodes.dta"
drop if _m==2
drop _m

gen     storetype = 1 if fascia=="Aldi"|fascia=="Asda"|fascia=="Lidl"|fascia=="Morrisons"|fascia=="Safeway"|fascia=="Sainsbury's (Supermarket)"|fascia=="Sainsbury's Local"|fascia=="Tesco (Supermarket)"|fascia=="Tesco Express"|fascia=="Tesco Extra"|fascia=="Tesco Metro"|fascia=="Waitrose"
replace storetype = 2 if fascia=="Boots"|fascia=="Budgens"|fascia=="Costcutter"|fascia=="Farm Foods"|fascia=="Greggs"|fascia=="Holland And Barrett"|fascia=="Iceland"|fascia=="Londis"|fascia=="Marks & Spencer"|fascia=="Netto"|fascia=="Nisa"|fascia=="Poundstretcher"|fascia=="Pret A Manger"|fascia=="Savacentre"|fascia=="Savers"|fascia=="Somerfield"|fascia=="Spar"|fascia=="Spar 8 Til Late"|fascia=="Subway"|fascia=="Superdrug"|fascia=="Thorntons"|fascia=="Total Co-Op Grocers"|fascia=="Toys R Us"|fascia=="Upper crust"|fascia=="W H Smith"|fascia=="Wilkinsons"
replace storetype = 3 if fascia=="Vending machine"
replace storetype = 4 if storetype==.
 
lab def st 1 "National-large" 2 "National-small" 3 "Vending machine" 4 "Regional" 
lab val storetype st

sa "$P\passthroughdesc.dta",replace


