
global P  "$dap"


use "M:\NDNS\Data\Stata_raw/ndns_yr1-3a_foodleveldietarydata.dta",clear

**Based on soft drinks
gen soda = MainFoodGroupCode==57|MainFoodGroupCode==58

**Most individuals in data for 4 days, though a few in for 3
bysort seriali DayNo: gen temp = 1 if _n==1
egen day = sum(temp),by(seriali)

rename Non_milk_extrinsic_sugars_g added_sugar
rename Energy_kcal energy

collapse (sum) added_sugar energy (max) day,by(seriali soda)

replace added_sugar = (1/day)*added_sugar
replace energy      = (1/day)*energy
drop day

fillin seriali soda

replace added_sugar = 0 if added_sugar==.
replace energy      = 0 if energy==.

gen sodsug = added_sugar if soda==1
gen sodeng = energy      if soda==1

egen totsug = sum(added_sugar),by(seriali)
egen toteng = sum(energy),by(seriali)

drop if soda==0
drop soda _f added_sugar energy

merge 1:1 seriali using "M:\NDNS\Data\Stata_raw/ndns_yr1-3indiva.dta",keepusing(hhinc age DMHSize Sex)
keep if _m==3
drop _m

gen hheqsize = (0.67+(DMHSize-1)*0.33)/0.67

rename hhinc hhinc_raw
gen hhinc     =  2500 if hhinc_raw==1
replace hhinc =  7500 if hhinc_raw==2
replace hhinc = 12500 if hhinc_raw==3
replace hhinc = 17500 if hhinc_raw==4
replace hhinc = 22500 if hhinc_raw==5
replace hhinc = 27500 if hhinc_raw==6
replace hhinc = 32500 if hhinc_raw==7
replace hhinc = 37500 if hhinc_raw==8
replace hhinc = 42500 if hhinc_raw==9
replace hhinc = 47500 if hhinc_raw==10

gen hhinc_eq=hhinc/hheqsize

**Calories from added sugar
gen calsug = 4*totsug
**Share of calories from added sugar
gen shrsug = (calsug/toteng)*100

sa "$P/NDNS.dta",replace

