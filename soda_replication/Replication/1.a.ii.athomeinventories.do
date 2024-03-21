
u "M:/TNS/extractedfiles/index_files/dates_detail.dta" ,clear

drop date
gen long date=year*10000+month*100+dayofmonth

drop yearweek yearweek_new demyear dayofweek weekday dayofmonth
drop if date<20090000|date>20160000

sort date
gen daysk = _n

keep date daysk 

gen i = 1

sa "$P/day_stock.dta",replace

u "M:\TNS\extractedfiles\purchase_data\Clean_data_by_rfy/CleanRF_84_2009.dta",clear
gen rf = 59
forv y = 2009(1)2015 {
	append using "M:\TNS\extractedfiles\purchase_data\Clean_data_by_rfy/CleanRF_84_`y'.dta"
	replace rf = 59 if rf==.
}	

foreach n of numlist 84 190 647 648 649 650 651 652 654 655 656 657 658 659 1177 1179 1181 1234 1341 1342 1343 1344 {
	forv y = 2009(1)2015 {
		append using "M:\TNS\extractedfiles\purchase_data\Clean_data_by_rfy/CleanRF_`n'_`y'.dta"
		replace rf = `n' if rf==.
	}
}

**Soft drinks with sugar
gen     type = 1 if (rf==647|rf==648|rf==656|rf==657|rf==658|rf==659)&sugar>0
**Diet soft drinks 
replace type = 2 if (rf==647|rf==648|rf==656|rf==657|rf==658|rf==659)&sugar==0
**Fruit juice 
replace type = 3 if rf==1177|rf==1179|rf==1181
**Flavored milk
replace type = 4 if rf==1341
**Flavored water
replace type = 5 if (rf==84|rf==654|rf==655)&sugar>0
**Water
replace type = 6 if (rf==84|rf==654|rf==655)&sugar==0
**Other
replace type = 7 if type==.

lab def type 1 "Sugary soft drinks" 2 "Diet soft drinks" 3 "Fruit juice" 4 "Flavoured milk" 5 "Flavoured water" 6 "Water" 7 "Misc drinks"
lab val type type

keep hhno date prodcode volume npacks expenditure shopcode shopid promcode sugars type

centile volume,centile(1 99)
drop if volume<r(c_1)|volume>r(c_2)

merge m:1 date using "$P\day_stock.dta"
drop if _m==2
drop _m

merge m:1 hhno using "$P/hhno_sample.dta"
keep if _m==3
drop _m  

sa "$P/raw_athomedrinks.dta",replace

u "$P/raw_athomedrinks.dta",clear

collapse (sum) volume,by(hhno daysk date type)

reshape wide volume,i(hhno daysk date) j(type)

rename volume1 Qssoft
rename volume2 Qdsoft
rename volume3 Qfruit
rename volume4 Qfmilk
rename volume5 Qfwater
rename volume6 Qwater
rename volume7 Qmisc

egen minday = min(daysk),by(hhno)
egen maxday = max(daysk),by(hhno)

sa "$P/athomedrinktypes.dta",replace

foreach v in ssoft dsoft fruit fmilk fwater water misc {
	u "$P/athomedrinktypes.dta",clear

	keep hhno daysk Q`v'
	keep if Q`v'!=.
	sort hhno daysk
	by hhno: gen d`v' = daysk-daysk[_n-1]
	
	sa "$P/days`v'.dta",replace
}

u "$P/athomedrinktypes.dta",clear

foreach v in ssoft dsoft fruit fmilk fwater water misc {
	merge m:1 hhno daysk using "$P/days`v'.dta"
	drop _m
}

sa "$P/athomedrinktypes_days.dta",replace


use "M:\TNS\extractedfiles\panel_data\hhcharacteristics.dta",clear

merge m:1 hhno using "$P/hhno_sample.dta"
keep if _m==3
drop _m  

keep hhno demyear adequiv
rename demyear year

fillin hhno year
drop _f

replace adequiv=adequiv[_n-1] if adequiv==.

keep if year>2008 & year<2015

sa "$P/hhno_adequiv.dta",replace

u "$P/hhno_sample.dta",clear

gen i = 1

joinby i using "$P/day_stock.dta"

merge 1:1 hhno day using "$P/athomedrinktypes_days.dta"
drop  if _m==2
drop _m

egen temp = min(minday),by(hhno)
replace minday=temp
drop temp
egen temp = min(maxday),by(hhno)
replace maxday=temp
drop temp

drop if day<minday | day>maxday

sort hhno day
foreach v in ssoft dsoft fruit fmilk fwater water misc {
	forv x =1/2000 {
		by hhno: replace d`v' = d`v'[_n+1]-1 if Q`v'==.
	}

	replace Q`v' = 0 if Q`v'==.

	by hhno: egen mc`v' = mean(Q`v')

	gen temp = Q`v'
	replace temp = temp[_n-1] if temp==0
	gen inv`v' = temp-d`v'[_n+1]*mc`v'
	replace inv`v' = 0 if inv`v'<0
	replace inv`v' = 0 if inv`v'==.
	drop temp
}

drop daysk
merge m:1 date using "$P/week.dta"
keep if _m==3
drop _m

merge m:1 hhno year using "$P/hhno_adequiv.dta"
drop if _m==2
drop _m

foreach v in Q d mc inv {
    foreach x in ssoft dsoft fruit fmilk water fwater misc {
        replace `v'`x'=`v'`x'/adequiv 
    }
}

keep  hhno day Qssoft dssoft mcssoft invssoft Qdsoft ddsoft mcdsoft invdsoft Qfruit dfruit mcfruit invfruit Qfmilk dfmilk mcfmilk invfmilk Qfwater dfwater mcfwater invfwater Qwater dwater mcwater invwater Qmisc dmisc mcmisc invmisc
order hhno day Qssoft dssoft mcssoft invssoft Qdsoft ddsoft mcdsoft invdsoft Qfruit dfruit mcfruit invfruit Qfmilk dfmilk mcfmilk invfmilk Qfwater dfwater mcfwater invfwater Qwater dwater mcwater invwater Qmisc dmisc mcmisc invmisc
          
sa "$P/athome_inventories.dta",replace

