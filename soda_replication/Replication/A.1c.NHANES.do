
global M  "$nhan"
global P  "$dap"

**************************
** NHANES DEMO DATA
**************************

local j=1
foreach y in 20072008 20092010 {
	u "M:/NHANES/Data/Demo`y'.dta", clear
	gen hheqsize = (0.67+(dmdhhsiz-1)*0.33)/0.67
	keep seqn riagendr ridageyr indhhin2 indfmin2 hheqsize
    gen year=`y' 
    compress  
	if `j'>1 append using "$P/demo.dta"
    so seqn year
	sa "$P/demo.dta", replace
    local j=`j'+1
}
foreach y in 20112012 20132014 {
	u "M:/NHANES/Data/Demo`y'.dta", clear
	gen nad = dmdhhsiz-dmdhhsza-dmdhhszb
	gen hheqsize = (0.67+(nad-1)*0.33)/0.67 + (0.2*dmdhhsza+0.33*dmdhhszb)/0.67 
	keep seqn riagendr ridageyr indhhin2 indfmin2 hheqsize
    gen year=`y' 
    compress  
	if `j'>1 append using "$P/demo.dta"
    so seqn year
	sa "$P/demo.dta", replace
    local j=`j'+1
}



**************************
** NHANES CONSUMPTION DATA
**************************

local j=1

foreach y in 20072008 20092010 20112012 20132014 {
foreach x in First Second	{
	u "M:/NHANES/Data/IndFoods`x'Day`y'.dta", clear

	**get food code variable name from food codes file
	if "`x'" == "First" 	ren dr1ifdcd drxfdcd
	if "`x'" == "Second" 	ren dr2ifdcd drxfdcd

	merge m:1 drxfdcd using "M:/NHANES/Data/FoodCodes`y'.dta",keep(match)
	drop _m
    gen usda1d=int(drxfdcd/10000000)
    gen usda2d=int(drxfdcd/1000000)
    gen usda3d=int(drxfdcd/100000)
    gen usda4d=int(drxfdcd/10000)

    gen prod=99
    replace prod = 1 if usda3d==924|usda4d==9531|usda4d==9532 /*soft drinks, carbonated */
    replace prod = 2 if usda1d==9&(usda3d~=924&usda2d~=93&usda4d~=9531&usda4d~=9532)  /*sweets and sugar nonsoda drinks*/
    replace prod = 3 if usda2d==93 /*alcohol*/
    
    ** fruit juice, milk 
    replace prod = 4 if usda2d==64|usda3d==672|usda3d==743|usda3d==781 /*fruit juice*/
    replace prod = 5 if usda2d==11 /*milk*/
    
    ** water
    replace prod = 6 if usda2d==94  /*water*/
	
	**dairy and fruits and veg
    replace prod = 11 if prod==.&(usda1d==1|usda1d==6|usda1d==7) /*dairy and fruits and veg*/

	if "`x'" == "First" {
        gen home = dr1_040z
        gen sugarcal = dr1isugr*4
        gen cal_sum = (dr1iprot+dr1icarb)*4 + dr1itfat*9
        gen calories = dr1ikcal
        ren dr1isugr sugargm
 	}
	if "`x'" == "Second" {
        gen home = dr2_040z
        gen sugarcal = dr2isugr*4
        gen cal_sum = (dr2iprot+dr2icarb)*4 + dr2itfat*9
        gen calories = dr2ikcal
        ren dr2isugr sugargm
	}
    replace home=2 if home>2
	
    gen shr=calories/cal_sum
	sa "$P/NHANES`x'`y'.dta", replace

	collapse (sum) calories cal_sum sugarcal sugargm (mean) drdint, by(seqn home prod)
    fillin seqn home prod
    mvdecode calories cal_sum sugarcal sugargm,mv(0)
    mvencode calories cal_sum sugarcal sugargm,mv(0)

    gen double year=`y'
    format year %15.0f

	if `j'>1 append using "$P/NHANES.dta"
	sa "$P/NHANES.dta", replace
    local j=`j'+1
}
}

collapse (sum) calories cal_sum sugarcal sugargm (mean) drdint, by(seqn year home prod)
egen temp=max(drdint),by(seqn year)
drop drdint
ren temp drdint


foreach v in calories cal_sum sugarcal sugargm {
    replace `v' = `v'/drdint
}

reshape wide calories cal_sum sugarcal sugargm,j(home) i(seqn year prod)

forval h=1(1)2 {

   egen CAL`h'=total(cal_sum`h'),by(seqn year)
   egen SUGCAL`h'=total(sugarcal`h'),by(seqn year)
   egen SUGGM`h'=total(sugargm`h'),by(seqn year)

   gen temp = sugarcal`h' if prod~=4&prod~=5&prod~=11
   egen SUGCALADD`h'=max(temp),by(seqn year)
   drop temp
   
   gen temp = sugarcal`h' if prod==1
   egen SUGCALSODA`h'=sum(temp),by(seqn year)
   drop temp

   gen temp = sugargm`h' if prod==1
   egen SUGGMSODA`h'=sum(temp),by(seqn year)
   drop temp
}

lab var CAL1 "Total calories home by seqn year"
lab var CAL2 "Total calories out by seqn year"
lab var SUGCAL1 "Total sugar calories home by seqn year"
lab var SUGCAL2 "Total sugar calories out by seqn year"
lab var SUGGM1 "Total sugar gm home by seqn year"
lab var SUGGM2 "Total sugar gm out by seqn year"


lab var SUGCALADD1 "Total sugar calories home by seqn year"
lab var SUGCALADD2 "Total sugar calories out by seqn year"
lab var SUGCALSODA1 "Total sugar calories home from soda by seqn year"
lab var SUGCALSODA2 "Total sugar calories out from soda by seqn year"
lab var SUGGMSODA1 "Total sugar gm home from soda by seqn year"
lab var SUGGMSODA2 "Total sugar gm out from soda by seqn year"

lab def prod  1 "Soda" 2 "Other sugary drinks" 3 "Alcohol" 4 "Fruit juice" 5 "Milk" 6 "Water" 11 "Milk and fruit and veg" 99 "Other foods"
lab val prod prod
lab var prod "Product"
lab var cal_sum1 "Calories by summing nutrients home"
lab var cal_sum2 "Calories by summing nutrients out"
lab var drdint "Number of days of intake"
forval h=1(1)2 {
   lab var sugarcal`h' "Energy from sugar (kcal)"
   lab var calories`h' "Energy (kcal)"
   lab var sugargm`h' "Sugar (gm)"
}

compress
sa "$P/NHANES.dta", replace

u "$P/NHANES.dta",clear

so seqn year
mer m:1 seqn year using "$P/demo.dta",keep(match)
drop _m
gen male=riagendr==1
drop riagendr
lab var male "=1 if male"

gen hhinc     =  2500 if indhhin2==1
replace hhinc =  7500 if indhhin2==2
replace hhinc = 12500 if indhhin2==3
replace hhinc = 17500 if indhhin2==4
replace hhinc = 22500 if indhhin2==5
replace hhinc = 30000 if indhhin2==6
replace hhinc = 40000 if indhhin2==7
replace hhinc = 50000 if indhhin2==8
replace hhinc = 60000 if indhhin2==9
replace hhinc = 70000 if indhhin2==10

gen inc_eq = hhinc/hheqsize


gen SUGCALADD=SUGCALADD1+SUGCALADD2
lab var SUGCALADD "Calories from added sugar"
gen SUGCALSHR=SUGCALADD/(CAL1+CAL2)
lab var SUGCALSHR "Share of calories from added sugar"

gen SUGCALSHR1=(SUGCALADD1/CAL1)
lab var SUGCALSHR1 "Share of calories from added sugar home"
gen SUGCALSHR2=(SUGCALADD2/CAL2)
lab var SUGCALSHR2 "Share of calories from added sugar out"

gen SUGCALSODA=SUGCALSODA1+SUGCALSODA2
lab var SUGCALSODA "Calories from added sugar in soda"
gen SUGCALSODASHR=SUGCALSODA/SUGCALADD
lab var SUGCALSODASHR "Share of calories from added sugar from soda"

gen SUGCALSODASHR1=SUGCALSODA1/SUGCALADD
lab var SUGCALSODASHR1 "Share of calories from added sugar from soda home"
gen SUGCALSODASHR2=SUGCALSODA2/SUGCALADD
lab var SUGCALSODASHR2 "Share of calories from added sugar from soda out"


so seqn year
qui by seqn year:gen f=1 if _n==1

replace SUGCALSHR=SUGCALSHR*100 
replace SUGCALSODASHR=SUGCALSODASHR*100 
replace SUGCALSODASHR2=SUGCALSODASHR2*100

sa "$P/NHANES_gph.dta", replace
