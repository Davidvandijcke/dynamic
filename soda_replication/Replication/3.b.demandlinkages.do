
clear
cap log close
set more off
set matsize 10000

global P "$cd"
global D "$ds"

********************************************************************************************
**Demand side linkages
********************************************************************************************

use "$P/FOTGpurchases.dta", clear

merge m:1 prodcode using "$P/attributes.dta"
drop if _m==2
drop _m

merge m:1 hhno indvno using "$P/indvno_sample.dta"
drop if day<entry | day>exit
drop _m indemand entry exit 

drop volume
gen    volume = (pack/1000)*npack
replace volume = 0 if prodagg==.

gen price = expenditure/npack

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

gen volumesoft = 0
replace volumesoft = volume if product<110
    
collapse (sum) volumesoft volume,by(hhno indvno day month year)

centile volume if volume>0,centile(99)
drop if volume>r(c_1)

sa "$D/volume_out.dta",replace

u "$D/volume_out.dta",clear

egen dmindex = group(hhno indvno)

keep dmindex day hhno indvno month year

egen min = min(day),by(dmindex)
egen max = max(day),by(dmindex)

fillin dmindex day
drop _fillin

egen temp = min(hhno),by(dmindex)
replace hhno = temp if hhno==.
drop temp
egen temp = min(indvno),by(dmindex)
replace indvno = temp if indvno==.
drop temp

egen temp = min(month),by(day)
replace month = temp if month==.
drop temp
egen temp = min(year),by(day)
replace year = temp if year==.
drop temp

egen mint = min(min),by(dmindex)
egen maxt = min(max),by(dmindex)

drop if day<mint | day>maxt
drop min* max*

sa "$D/link_days.dta",replace

u "$D/link_days.dta",clear

merge m:1 hhno indvno using "M:/TNS/extractedfiles/fotg_data/age_sex_full.dta",keepusing(region)
drop _m

merge 1:1 hhno indvno day using "$D/volume_out.dta"
drop _m

gen     volout = volume
replace volout = 0 if volout==.
drop volume

gen     volsoftout = volumesoft
replace volsoftout = 0 if volumesoft==.
drop volumesoft

merge m:1 hhno day using "$P/athome_inventories.dta",keep(match) keepusing(invssoft invdsoft invssoft invdsoft invfruit invfmilk invfwater invwater invmisc)
drop _m

gen invdrks = invssoft+invdsoft+invfruit+invfmilk+invfwater+invwater+invmisc
gen invsoft = invssoft+invdsoft

sort dmindex day

sa "$D/link_days2.dta",replace

use "$P/raw_athomedrinks.dta",clear

keep if type==1|type==2

collapse (sum) volume,by(hhno date)

centile volume if volume>0,centile(99)
drop if volume>r(c_1)

merge m:1 date using "$P/week.dta"
keep if _m==3
drop _m

rename volume volsoftin 
keep hhno day volsoftin 

sa "$D/volume_in.dta",replace

u "M:/TNS/extractedfiles/fotg_data/panel_all.dta",clear

keep hhno indvno demyear gender class age hhsize children
duplicates drop

rename demyear year
egen dm = group(hhno indvno)

fillin dm year
drop _f

egen temp = min(hhno),by(dm)
replace hhno = temp if hhno==.
drop temp
egen temp = min(indvno),by(dm)
replace indvno = temp if indvno==.
drop temp

replace hhsize = . if hhsize==0

sort dm year
forv x = 1/8 {
  foreach v in class gender hhsize children {
	by dm: replace `v' = `v'[_n-1] if `v'==.
	by dm: replace `v' = `v'[_n+1] if `v'==.
  }	
  by dm: replace age = age[_n-1]+1 if age==.
  by dm: replace age = age[_n+1]-1 if age==.
}
drop dm

sa "$D/rf_demogs.dta",replace

u "$D/link_days2.dta",clear

egen ym = group(year month)

gen ymr=ym*100 + region

centile invdrks,centile(99)
drop if invdrks>r(c_1)

gen Dvolout     = volout>0
gen Dvolsoftout = volsoftout>0

merge m:1 hhno day using "$D/volume_in.dta"
drop if _m==2
drop _m

replace volsoftin=0 if volsoftin==.

merge m:1 hhno indvno year using "$D/rf_demogs.dta"
drop if _m==2
drop _m

tsset dmindex   day

gen volsoftinweek=.
foreach d of numlist 0/21 {
	foreach dd of numlist 1/100 {
		local ddd=`d'*100+`dd'
	egen tmp=sum(volsoftin*(day<=`ddd')*(day>`ddd'-7)) , by(dmindex)
    replace volsoftinweek=tmp if day==`ddd' & volsoftinweek==.
	drop tmp
	}
}

merge m:1 hhno year using "$D/demogs.dta",keepusing(hheqsize)
drop if _m==2
drop _m

egen temp = mean(hheqsize),by(hhno)
replace hheqsize = temp if hheqsize==.
drop temp

replace volsoftinweek=volsoftinweek/hheqsize
replace invsoft=invsoft/hheqsize

sort dmindex day
by dmindex: gen invsoftlag = invsoft[_n-7]

qui compress

keep  dmindex hhno day Dvolsoftout volsoftout volsoftinweek invsoft invsoftlag ym region ymr gender class age hhsize children
order dmindex hhno day Dvolsoftout volsoftout volsoftinweek invsoft invsoftlag ym region ymr gender class age hhsize children

lab var dmindex       "Decision maker index"
lab var hhno          "Household index"
lab var day           "Day"
lab var Dvolsoftout   "Indicator of out purchase"
lab var volsoftout    "Volume of out purchase"
lab var volsoftinweek "Weekly food in purchases"
lab var invsoft       "Inventory in"
lab var invsoftlag    "Inventory in (1 week lag)"
lab var ym            "Year-month dummies"
lab var region        "Region dummies"
lab var ymr           "Year-month-region dummies"
lab var gender        "Gender"
lab var class         "Socioeconomic status"
lab var age           "Age"
lab var hhsize        "Household size"
lab var children      "Number of children"

sa "$D/demandlinkage.dta",replace
