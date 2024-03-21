global P0 "$cd"
global P2 "$ds"
global P  "$rs"

global G  "$rr"
global Gd "$dr"

**************************************************************************
**Descriptive 
**************************************************************************

*********
**Table 1
*********

u "$P2/Tdimstats.dta",clear

listtab group i0 perc0 using "$Gd/indvT1.tex", replace rstyle(tabular)

gen tot = 1

collapse (sum) i0 perc0,by(tot)

lab def tot 1 "Total"
lab val tot tot

listtab tot i0 perc0 using "$Gd/indvT2.tex", replace rstyle(tabular)

*********
**Table 2
*********

u "$P2/productstats.dta",clear

forv b = 1/10 {
	listtab o o product share price using "$Gd/products`b'p.tex" if brand==`b', replace rstyle(tabular)
}
listtab o o product share price using "$Gd/products100p.tex" if brand==100, replace rstyle(tabular)
listtab o brand o share price using "$Gd/products110p.tex" if brand==110, replace rstyle(tabular)
listtab o brand o share price using "$Gd/products120p.tex" if brand==120, replace rstyle(tabular)
listtab o brand o share price using "$Gd/products130p.tex" if brand==130, replace rstyle(tabular)
listtab o brand o share price using "$Gd/products140p.tex" if brand==140, replace rstyle(tabular)

collapse (sum) share,by(brand firm o)

forv b = 1/10 {
	listtab o brand o share o using "$Gd/products`b'b.tex" if brand==`b', replace rstyle(tabular)
}

collapse (sum) share,by(firm o)

forv b = 1/4 {
	listtab firm o o share o using "$Gd/products`b'f.tex" if firm==`b', replace rstyle(tabular)
}

*********
**Table 3
*********

u "$P2/storestats.dta",clear

listtab store store2 i0 share using "$Gd/stores.tex", replace rstyle(tabular)

collapse (sum) i0 share

gen tot = 1
lab def tot 1 "Total"
lab val tot tot
gen o=""

format %9.0fc i0

listtab tot o i0 share using "$Gd/stores2.tex", replace rstyle(tabular)

*********
**Table 4
*********

u "$P2/demandlinkage.dta",clear

reg     Dvolsoftout volsoftinweek, robust
estimates store rv1
estadd local inst       "No"
estadd local tim_reg    "No"
estadd local ind_fe     "No"
estadd local demo       "No"

ivreg     Dvolsoftout (volsoftinweek = invsoftlag), robust
estimates store rv2
estadd local inst       "Yes"
estadd local tim_reg    "No"
estadd local ind_fe     "No"
estadd local demo       "No"


tab ymr,gen(ymr)
ivreg     Dvolsoftout ymr2-ymr201 (volsoftinweek = invsoftlag) , robust
estimates store rv3
estadd local inst       "Yes"
estadd local tim_reg    "Yes"
estadd local ind_fe     "No"
estadd local demo       "No"


xtset dmindex day
xtivreg Dvolsoftout ymr2-ymr201 (volsoftinweek = invsoftlag), fe vce(robust)
estimates store rv4
estadd local inst       "Yes"
estadd local tim_reg    "Yes"
estadd local ind_fe     "Yes"
estadd local demo       "No"


replace hhsize   = 5 if hhsize>5
replace children = 3 if children>3
tab hhsize,gen(hh)
tab children,gen(ch)
tab class,gen(cl)
gen age1 = age<20
gen age2 = age<30&age>=20
gen age3 = age<40&age>=30
gen age4 = age<50&age>=40
gen age5 = age<60&age>=50
gen age6 = age<.&age>=60
xtivreg Dvolsoftout hh2-hh5 ch1-ch3 cl1 cl2 cl4 cl5 cl6 age2-age6 ymr2-ymr201 (volsoftinweek = invsoftlag), fe vce(robust)
estimates store rv5
estadd local inst       "Yes"
estadd local tim_reg    "Yes"
estadd local ind_fe     "Yes"
estadd local demo       "Yes"


#delimit ;
esttab  rv1 rv2 rv3 rv4 rv5 using "$Gd/inventory.tex", 
replace
order( volsoftinweek _cons)
nostar b(5) se(5)
stats(inst tim_reg ind_fe demo, fmt(%9.5f) labels("Instrument variable" "Time-region effects" "Individual effects" "Time-varying demographics"))
varlabels(_cons "Constant" volsoftinweek "At-home volume purchased") 
collabels(none) booktabs drop(female hh* ch* cl* age* ymr*)
nomtitles nonotes
 ;
#delimit cr



*********
**Table 5
*********

u "$P2/agestats.dta",clear

foreach x of numlist 1 2  {
    local vrname  :   label  (v)   `x'
    if `x'==1 listtab v1 v2 v3 v4 v5 v6 using "$Gd/age_desc1.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>1  listtab v1 v2 v3 v4 v5 v6 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/age_desc1.tex" )
}
foreach x of numlist 3 4  {
    local vrname  :   label  (v)   `x'
    if `x'==3 listtab v1 v2 v3 v4 v5 v6 using "$Gd/age_desc2.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>3  listtab v1 v2 v3 v4 v5 v6 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/age_desc2.tex" )
}
format v1 v2 v3 v4 v5 v6 %9.2f

foreach x of numlist 5 6 {
    local vrname  :   label  (v)   `x'
    if `x'==5 listtab v1 v2 v3 v4 v5 v6 using "$Gd/age_desc3.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>5  listtab v1 v2 v3 v4 v5 v6 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/age_desc3.tex" )
}

*********
**Table 6
*********

u "$P2/sugstats.dta",clear

foreach x of numlist 1 2  {
    local vrname  :   label  (v)   `x'
    if `x'==1 listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 using "$Gd/sug_desc1.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>1  listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/sug_desc1.tex" )
}
foreach x of numlist 3 4 {
    local vrname  :   label  (v)   `x'
    if `x'==3 listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 using "$Gd/sug_desc2.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>3  listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/sug_desc2.tex" )
}
format v1 v2 v3 v4 v5 v6 %9.2f

foreach x of numlist 5 6 {
    local vrname  :   label  (v)   `x'
    if `x'==5 listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 using "$Gd/sug_desc3.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>5  listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/sug_desc3.tex" )
}

*********
**Table 7
*********

u "$P2/expstats.dta",clear

foreach x of numlist 1 2  {
    local vrname  :   label  (v)   `x'
    if `x'==1 listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 using "$Gd/exp_desc1.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>1  listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/exp_desc1.tex" )
}
foreach x of numlist 3 4  {
    local vrname  :   label  (v)   `x'
    if `x'==3 listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 using "$Gd/exp_desc2.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>3  listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/exp_desc2.tex" )
}
format v1 v2 v3 v4 v5 v6 %9.2f

foreach x of numlist 5 6 {
    local vrname  :   label  (v)   `x'
    if `x'==5 listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 using "$Gd/exp_desc3.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>5  listtab v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 in `x', begin(`vrname'&)  rstyle(tabular)  appendto("$Gd/exp_desc3.tex" )
}

**************************************************************************
**Descriptive pass-through 
**************************************************************************

*********
**Table 8
*********

u "$P2\passthroughdesc.dta",clear

tab fascia,gen(st)
tab month,gen(mm)
gen small=(pack<400)
tab storetype,g(sstt)
gen coke12=(product==1|product==2)
gen coke1112=(product==11|product==12)
gen pepsi1617=(product==16|product==17)

reg price aftertreat coke1112 pepsi1617 small sstt2-sstt4 mm2-mm12 if hitreat==1
estimates store r1
reg price aftertreat coke1112 pepsi1617 small sstt2-sstt4 mm2-mm12 if small==1&hitreat==1
estimates store r2
reg price aftertreat coke1112 pepsi1617 small sstt2-sstt4 mm2-mm12 if small==0&hitreat==1
estimates store r3

#delimit ;
esttab r1 r2 r3  using "$Gd/passthroughregs.tex", 
replace
order(aftertreat) 
nostar b(3) se(3)
stats(N,fmt(%9.0g))
varlabels(_cons "Constant" aftertreat "After tax")  drop(coke1112 pepsi1617 small sstt* mm* )
collabels(none) booktabs mtitles("All" "330ml" "500ml")
nonotes nonumb;
#delimit cr
 

**************************************************************************
**Demand estimate
**************************************************************************

*********
**Table 9
*********

u "$P/coefficients1.dta",clear

format coef se %9.4f

listtab vr var coef se using "$G/pricecoef.tex"  if vr<5,rstyle(tabular)  replace
listtab vr var coef se using "$G/drinkscoef.tex" if vr>4&vr<9 ,rstyle(tabular)  replace
listtab vr var coef se using "$G/sugarcoef.tex"  if vr>8&vr<13,rstyle(tabular)  replace
listtab vr var coef se using "$G/covcoef.tex"    if vr>12&vr<16,rstyle(tabular)  replace


u "$P/coefficients2.dta",clear

format coef se %9.4f

listtab vr gp coef se using "$G/fixedcoef1.tex"  if n==1,rstyle(tabular)  replace
listtab vr gp coef se using "$G/fixedcoef2.tex"  if n==5,rstyle(tabular)  replace
listtab vr gp coef se using "$G/fixedcoef3.tex"  if n==6,rstyle(tabular)  replace


**************************************************************************
**Elasticities
**************************************************************************

*********
**Table 10
*********

u "$P/elasticitiestable.dta",clear

foreach x of numlist 37 38 {
    local vrname  :   label  (vr)   `x'
    if `x'==37 listtab own_out cross_d_out cross_ar_out cross_ad_out total_out using "$G/elas2.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>37 listtab own_out cross_d_out cross_ar_out cross_ad_out total_out in `x'  , begin(`vrname'&)  rstyle(tabular)  appendto("$G/elas2.tex" )
	listtab CIown_ CIcross_d_ CIcross_ar_ CIcross_ad_ CItotal_ in `x' ,   rstyle(tabular)  appendto("$G/elas2.tex")   begin(&)
    }

*****************************************************************
***Robustness
*****************************************************************
*********
**Table 11
*********

u "$P/passsum.dta",clear

listtab vr all sm lg if vr==1 & gp==1 using "$G/pass_summary.tex",rstyle(tabular)  replace
listtab vr all_out sm_out lg_out if vr>1 & gp==1 ,rstyle(tabular)  appendto("$G/pass_summary.tex")

listtab vr all sm lg if vr==1 & gp==0 using "$G/pass_summary2.tex",rstyle(tabular)  replace
listtab vr all_out sm_out lg_out if vr>1 & gp==0 ,rstyle(tabular)  appendto("$G/pass_summary2.tex")



