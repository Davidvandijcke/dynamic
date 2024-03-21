u "$P/FoodIn/all_purchases.dta",clear

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

**cwmystwyth closed from 2011 April onwards; use alternative Welsh station
gen close = location=="cwmystwyth"
replace close = 0 if year<2011
replace close = 0 if year==2011 & month<4
replace location = "aberporth" if close==1

merge m:1 location year month using "$P/weather.dta"
drop if _m==2
drop _m

foreach x in tmax tmin rain {
	bysort year month: egen temp = mean(`x')
	replace `x' = temp if `x' == .
	drop temp
}

keep hhno year month tmax tmin rain

sa "$P/FoodIn/hhym_weather_string_in.dta", replace 
