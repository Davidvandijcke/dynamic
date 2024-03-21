 
global P  "$rs"

set more off
forv m=1/66{
	global Ps "$P/Passthrough/`m'"
		 
	insheet using "$Ps/passthrough.raw", clear

	rename v1 optN
	rename v2 market
	rename v3 cost
	rename v4 preprice
	rename v5 postprice
	drop v6

	keep optN market cost *price

	merge 1:m optN using "$Ps/opmap.dta"
	drop _m
		
	drop optN
		
	sa "$Ps/pricechanges.dta",replace	
}	


	
u "$P/logit_coefficients.dta",clear	
	
keep csindex product prodagg year group order 

merge m:1 csindex using "$P/Passthrough/counterfacutalrm.dta"
keep if _m==3
drop _m

rename rmcount rm
merge m:1 rm year group order using "$P/Passthrough/submapping.dta"
drop if _m==2
drop _m

merge m:1 rm year prodagg using "$P/Passthrough/meanprice.dta"
drop if _m==2

egen temp = mean(price),by(prodagg year)
drop if _m==2
replace price = temp if price==.
drop _m prodagg temp

rename price pre_price

egen opt = group(product)

gen postpriceS1=.
gen margc=.

forv m=1/66{
	
		global Ps "$P/Passthrough/`m'"
		merge m:1 sub opt using "$Ps/pricechanges.dta",keepusing(preprice postprice cost) 
		drop if _m==2
		replace postpriceS1 = postprice if _m==3
		replace margc = cost if _m==3
		drop _m preprice postprice cost
}
rename margc cost		

gen pricerise1 = postpriceS1-pre_price

egen mnpr1 = mean(pricerise1),by(product rm)
replace postpriceS1 = pre_price+mnpr1 if postpriceS1==.
drop mnpr1 

egen mnpr1 = mean(pricerise1),by(product)
replace postpriceS1 = pre_price+mnpr1 if postpriceS1==.
drop mnpr1

egen temp = mean(cost),by(product rm)
replace cost = temp if cost==.
drop temp

egen temp = mean(cost),by(product)
replace cost = temp if cost==.
drop temp
rename postpriceS1 post_UK_price

keep csindex rm product cost pre_price post_UK_price 

foreach v in cost pre_price post_UK_price {
	replace `v' = 0 if product==199|product==999
}

sa "$P/Passthrough/pricesimulations.dta",replace
