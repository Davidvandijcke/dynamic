
global D "$dap"

global P  "$rs"
global P0 "$cd"
global P2 "$ds"

global G  "$rr"


*******************************
**NDNS Graphs
*******************************

u "$D/NDNS.dta",clear

****Figure  A1

**Added sugar
gen male = Sex==1
cumul calsug if male==1 & calsug<739,gen(c1)
cumul calsug if male==0 & calsug<568,gen(c0)

so calsug
#delimit ;
line c0 c1 calsug if calsug<739
,lc(black black) lw(thick thick) lp(solid dash) xline(100,lcolor(black) lpattern(solid)) xline(150,lcolor(black) lpattern(dash)) graphr(color(white)) bgcolor(white) legend(lab(1 "Females") lab(2 "Males")) xlabel(0(100)800)
xtitle("Calories from added sugar") ytitle("Cumulative density")
;
#delimit cr
drop c0 c1
graph export "$G/NDNS_cumaddsugcal.png",replace

**Share of calories from added sugar
centile shrsug,centile(99)
cumul shrsug if shrsug<=r(c_1),gen(c)
sort shrsug
centile shrsug,centile(99)
#delimit ;
line c shrsug   if shrsug<32
,lw(thick) lc(black) xline(5,lcolor(black) lpattern(dash)) graphr(color(white)) bgcolor(white) legend(off) xlabel(0(10)30)
xtitle("Share of calories from added sugar") ytitle("Cumulative density") title("") note("")
;
#delimit cr
drop c
graph export "$G/NDNS_cumaddsugshr.png",replace

****Figure  A2

#delimit ;
lpoly sodeng shrsug if shrsug<32 & soden<96.465
,nosc ci graphr(color(white)) bgcolor(white) legend(off) legend(off) 
xtitle("Share of calories from added sugar") ytitle("Calories from soft drinks") title("") note("")
;
#delimit cr
graph export "$G/NDNS_sodacalsug.png",replace

#delimit ;
lpoly sodeng age if  age<84 & age>12 & soden<96.465
,nosc ci graphr(color(white)) bgcolor(white) legend(off) legend(off) 
xtitle("Age") ytitle("Calories from soft drinks") title("") note("")
;
#delimit cr
graph export "$G/NDNS_sodacalage.png",replace

#delimit ;
lpoly sodeng hhinc_eq if hhinc_eq<35000 & soden<96.465
,nosc ci graphr(color(white)) bgcolor(white) legend(off) legend(off) bw(5000)
xtitle("Equivalized annnual household income (£)") ytitle("Calories from soft drinks") title("") note("")
;
#delimit cr
graph export "$G/NDNS_sodacalinc.png",replace


*******************************
**NHANES Graphs
*******************************

u "$D/NHANES_gph.dta",clear

****Figure  A3

cumul SUGCALSHR if f==1& SUGCALSHR<=35,gen(s)
so SUGCALSHR
#delimit ;
line s SUGCALSHR if f==1& SUGCALSHR<=35
,lc(black) lw(thick)  xline(5,lcolor(black) lpattern(dash)) graphr(color(white)) bgcolor(white) legend(off) 
xtitle("Share of calories from added sugar") ytitle("Cumulative density") title("") note("")
;
#delimit cr
graph export "$G/NHANES_cumaddsugcal.png",replace
drop s
cumul SUGCALADD if male==1&f==1 & SUGCALADD<964.48,gen(s1)
cumul SUGCALADD if male==0&f==1 & SUGCALADD<716.42,gen(s0)
so SUGCALADD
#delimit ;
line s0 s1 SUGCALADD if f==1&SUGCALADD<964.48
,lc(black black) lw(thick thick) lp(solid dash) xline(100,lcolor(black) lpattern(solid)) xline(150,lcolor(black) lpattern(dash)) graphr(color(white)) bgcolor(white) legend(lab(1 "Females") lab(2 "Males")) xlabel(0(100)900)
xtitle("Calories from added sugar") ytitle("Cumulative density")
;
#delimit cr
graph export "$G/NHANES_cumaddsugshr.png",replace
drop s0 s1

****Figure  A4

#delimit ;
lpoly SUGCALSODA SUGCALSHR if f==1 & SUGCALSHR<=35 & SUGCALSODA<622
,nosc ci graphr(color(white)) bgcolor(white) legend(off) legend(off) 
xtitle("Share of calories from added sugar") ytitle("Calories from soft drinks") title("") note("")
;
#delimit cr
graph export "$G/NHANES_sodacalsug.png",replace

#delimit ;
lpoly SUGCALSODA ridageyr if f==1&ridageyr>12&ridageyr<80 & SUGCALSODA<622
,nosc ci graphr(color(white)) bgcolor(white) legend(off) legend(off) xlabel(20(20)80)
xtitle("Age") ytitle("Calories from soft drinks") title("") note("")
;
#delimit cr
graph export "$G/NHANES_sodacalage.png",replace

#delimit ;
lpoly SUGCALSODA inc_eq if f==1 & inc_eq<=50000 & SUGCALSODA<622
,nosc ci graphr(color(white)) bgcolor(white) legend(off) legend(off) bw(5000) 
xtitle("Equivalized annnual household income ($)") ytitle("Calories from soft drinks") title("") note("")
;
#delimit cr
graph export "$G/NHANES_sodacalinc.png",replace

***************
**Prices
***************
u "$D/price_app1.dta",clear

**Figures A5-A6
hist dp,frac xtitle(Difference between transaction price and smoothed price) ytitle(Fraction of sample)  width(0.01)
graph export "$G\dtransactionprice.png",replace

forval r=1(1)6 {
	hist dp if rm==`r',frac xtitle(Difference between transaction price and smoothed price) ytitle(Fraction of sample)  width(0.01)
	graph export "$G\dtransactionprice_rm`r'.png",replace
}

*******************************
**on-the-go additional results
*******************************

u "$P/coefs_consumer.dta",clear

**************
**Figure B.1
**************

centile coef_price,centile(2.5 97.5)
gen lp = r(c_1)
gen up = r(c_2)
centile coef_drinks,centile(2.5 97.5)
gen ld = r(c_1)
gen ud = r(c_2)
centile coef_sugar,centile(2.5 97.5)
gen ls = r(c_1)
gen us = r(c_2)

kdens2 coef_price coef_drinks if coef_price>lp & coef_price<up & coef_drinks>ld & coef_drinks<ud,level(20) graphr(color(white)) bgcolor(white) xtitle("Drinks preference parameter") ytitle("Price preference parameter") title("") replace
graph export "$G/kden_pricesoft_count.png" ,replace
kdens2 coef_price coef_sugar  if coef_price>lp & coef_price<up & coef_sugar>ls & coef_sugar<us,level(20) graphr(color(white)) bgcolor(white) xtitle("Drinks preference parameter") ytitle("Sugar preference parameter") title("") replace
graph export "$G/kden_pricesugar_count.png",replace
kdens2 coef_drinks coef_sugary  if coef_sugar>ls & coef_sugar<us & coef_drinks>ld & coef_drinks<ud,level(20) graphr(color(white)) bgcolor(white) xtitle("Sugar preference parameter") ytitle("Drinks preference parameter") title("") replace
graph export "$G/kden_softsugar_count.png",replace



**************
**Table B.1
**************

u "$P/elasticitiestable.dta",clear

foreach x of numlist 1(1)30 {
    local vrname  :   label  (vr)   `x'
    if `x'==1 listtab own_out cross_r_out cross_d_out cross_ar_out cross_ad_out total_out using "$G/elasfullA.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>1  listtab own_out cross_r_out cross_d_out cross_ar_out cross_ad_out total_out in `x'  , begin(`vrname'&)  rstyle(tabular)  appendto("$G/elasfullA.tex" )
	listtab CIown_ CIcross_r_ CIcross_d_ CIcross_ar_ CIcross_ad_ CItotal_ in `x' ,   rstyle(tabular)  appendto("$G/elasfullA.tex")   begin(&)

    }
foreach x of numlist 32(1)36 {
    local vrname  :   label  (vr)   `x'
    if `x'==1 listtab own_out cross_r_out cross_d_out cross_ar_out cross_ad_out total_out using "$G/elasfullB.tex" in `x' , begin(`vrname'&)  rstyle(tabular)  replace
    if `x'>1  listtab own_out cross_r_out cross_d_out cross_ar_out cross_ad_out total_out in `x'  , begin(`vrname'&)  rstyle(tabular)  appendto("$G/elasfullB.tex" )
	listtab CIown_ CIcross_r_ CIcross_d_ CIcross_ar_ CIcross_ad_ CItotal_ in `x' ,   rstyle(tabular)  appendto("$G/elasfullB.tex")   begin(&)

    }

**************
**Table B.2
**************

***By age-gender

u "$P2/hhpurch_base.dta",clear

merge 1:1 hhno indvno using "$P/coefs_consumer.dta"
gen female=group==1|group==2
keep if _m==3
drop _m

gen sugpinf=sugar_prev==1
gen sugninf=sugar_prev==2

collapse (mean) coef_price coef_sugary coef_drinks sugpinf sugninf,by(agecat female)

#delimit ;
scatter sugpinf sugninf agecat if female==1,mc(black gs8)||
line    sugpinf agecat if female==1,lc(black) lpattern(shortdash) ||
line    sugninf  agecat if female==1,lc(gs8) lpattern(shortdash) ||
scatter sugpinf sugninf agecat if female==0,mc(black gs8) ms(Oh Oh)||
line    sugpinf agecat if female==0,lc(black) lpattern(dash) ||
line    sugninf  agecat if female==0,lc(gs8) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Proportion of individuals") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 2 5 6) lab(1 "Positive infinite; female") lab(2 "Negative infinite; female") lab(5 "Positive infinite; male") lab(6 "Negative infinite; male"))  ylabel(0(0.01)0.03);
#delimit cr
graph export "$G/inf_sugar_age_gender.png",replace

#delimit ;
scatter coef_sugar agecat if female==1,mc(black)||
line    coef_sugar agecat if female==1,lc(black) lpattern(shortdash)||
scatter coef_sugar agecat if female==0,mc(black) ms(Oh)||
line    coef_sugar agecat if female==0,lc(black) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 3) lab(1 "Female") lab(3 "Male"))  ylabel(-0.5(0.5)1.5);
#delimit cr
graph export "$G/sugar_coef_age_gender.png",replace

#delimit ;
scatter coef_price agecat if female==1,mc(black)||
line    coef_price agecat if female==1,lc(black) lpattern(shortdash) ||
scatter coef_price agecat if female==0,mc(black) ms(Oh)||
line    coef_price agecat if female==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 3) lab(1 "Female") lab(3 "Male"))  ylabel(-4(0.5)-2);
#delimit cr
graph export "$G/price_coef_age_gender.png",replace

#delimit ;
scatter coef_drink agecat if female==1,mc(black)||
line    coef_drink agecat if female==1,lc(black) lpattern(shortdash) ||
scatter coef_drink agecat if female==0,mc(black) ms(Oh)||
line    coef_drinks agecat if female==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Drinks preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 3) lab(1 "Female") lab(3 "Male")) ylabel(2(0.5)4);
#delimit cr
graph export "$G/drinks_coef_age_gender.png",replace

**************
**Table B.3
**************

***By sugar-gender

u "$P2/hhpurch_base.dta",clear


merge 1:1 hhno indvno using "$P/coefs_consumer.dta"
gen female=group==1|group==2
keep if _m==3
drop _m

gen sugpinf=sugar_prev==1
gen sugninf=sugar_prev==2

collapse (mean) coef_price coef_sugary coef_drinks sugpinf sugninf,by(asgrp female)

#delimit ;
scatter sugpinf sugninf asgrp if female==1,mc(black gs8)||
line    sugpinf asgrp if female==1,lc(black) lpattern(shortdash) ||
line    sugninf asgrp if female==1,lc(gs8) lpattern(shortdash) ||
scatter sugpinf sugninf asgrp if female==0,mc(black gs8) ms(Oh Oh)||
line    sugpinf asgrp if female==0,lc(black) lpattern(dash) ||
line    sugninf asgrp if female==0,lc(gs8) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Proportion of individuals") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 2 5 6) lab(1 "Positive infinite; female") lab(2 "Negative infinite; female") lab(5 "Positive infinite; male") lab(6 "Negative infinite; male")) ylabel(0(0.01)0.03);
#delimit cr
graph export "$G/inf_sugar_adds_gender.png",replace

#delimit ;
scatter coef_sugar asgrp if female==1,mc(black)||
line    coef_sugar asgrp if female==1,lc(black) lpattern(shortdash)||
scatter coef_sugar asgrp if female==0,mc(black) ms(Oh)||
line    coef_sugar asgrp if female==0,lc(black) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 3) lab(1 "Female") lab(3 "Male"))  ylabel(-0.5(0.5)1.5);
#delimit cr
graph export "$G/sugar_coef_adds_gender.png",replace

#delimit ;
scatter coef_drink asgrp if female==1,mc(black)||
line    coef_drink asgrp if female==1,lc(black) lpattern(shortdash) ||
scatter coef_drink asgrp if female==0,mc(black) ms(Oh)||
line    coef_drinks asgrp if female==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Drinks preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 3) lab(1 "Female") lab(3 "Male"))  ylabel(2(0.5)4);
#delimit cr
graph export "$G/drinks_coef_adds_gender.png",replace

#delimit ;
scatter coef_price asgrp if female==1,mc(black)||
line    coef_price asgrp if female==1,lc(black) lpattern(shortdash) ||
scatter coef_price asgrp if female==0,mc(black) ms(Oh)||
line    coef_price asgrp if female==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 3) lab(1 "Female") lab(3 "Male"))  ylabel(-4(0.5)-2);
#delimit cr
graph export "$G/price_coef_adds_gender.png",replace


**************
**Table B.4
**************

***By age-class


u "$P2/hhpurch_base.dta",clear


merge 1:1 hhno indvno using "$P/coefs_consumer.dta"
keep if _m==3
drop _m

gen sugpinf=sugar_prev==1
gen sugninf=sugar_prev==2

collapse (mean) coef_price coef_sugary coef_drinks sugpinf sugninf,by(agecat hcl)

#delimit ;
scatter sugpinf sugninf agecat if hcl==1,mc(black gs8)||
line    sugpinf agecat if hcl==1,lc(black) lpattern(shortdash) ||
line    sugninf  agecat if hcl==1,lc(gs8) lpattern(shortdash) ||
scatter sugpinf sugninf agecat if hcl==0,mc(black gs8) ms(Oh Oh)||
line    sugpinf agecat if hcl==0,lc(black) lpattern(dash) ||
line    sugninf  agecat if hcl==0,lc(gs8) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Proportion of individuals") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 2 5 6) lab(1 "Positive infinite; high") lab(2 "Negative infinite; high") lab(5 "Positive infinite; low") lab(6 "Negative infinite; low")) ylabel(0(0.01)0.03);
#delimit cr
graph export "$G/inf_sugar_age_class.png",replace

#delimit ;
scatter coef_sugar agecat if hcl==1,mc(black)||
line    coef_sugar agecat if hcl==1,lc(black) lpattern(shortdash)||
scatter coef_sugar agecat if hcl==0,mc(black) ms(Oh)||
line    coef_sugar agecat if hcl==0,lc(black) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 3) lab(1 "High") lab(3 "Low")) ylabel(-0.5(0.5)1.5);
#delimit cr
graph export "$G/sugar_coef_age_class.png",replace

#delimit ;
scatter coef_drink agecat if hcl==1,mc(black)||
line    coef_drink agecat if hcl==1,lc(black) lpattern(shortdash) ||
scatter coef_drink agecat if hcl==0,mc(black) ms(Oh)||
line    coef_drinks agecat if hcl==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Drinks preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 3) lab(1 "High") lab(3 "Low")) ylabel(2(0.5)4);
#delimit cr
graph export "$G/drinks_coef_age_class.png",replace

#delimit ;
scatter coef_price agecat if hcl==1,mc(black)||
line    coef_price agecat if hcl==1,lc(black) lpattern(shortdash) ||
scatter coef_price agecat if hcl==0,mc(black) ms(Oh)||
line    coef_price agecat if hcl==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 3) lab(1 "High") lab(3 "Low")) ylabel(-4(0.5)-2);
#delimit cr
graph export "$G/price_coef_age_class.png",replace



**************
**Table B.5
**************

**By added sugar-class

u "$P2/hhpurch_base.dta",clear


merge 1:1 hhno indvno using "$P/coefs_consumer.dta"
keep if _m==3
drop _m

gen sugpinf=sugar_prev==1
gen sugninf=sugar_prev==2

collapse (mean) coef_price coef_sugary coef_drinks sugpinf sugninf,by(asgrp hcl)


#delimit ;
scatter sugpinf sugninf asgrp if hcl==1,mc(black gs8)||
line    sugpinf asgrp if hcl==1,lc(black) lpattern(shortdash) ||
line    sugninf asgrp if hcl==1,lc(gs8) lpattern(shortdash) ||
scatter sugpinf sugninf asgrp if hcl==0,mc(black gs8) ms(Oh Oh)||
line    sugpinf asgrp if hcl==0,lc(black) lpattern(dash) ||
line    sugninf asgrp if hcl==0,lc(gs8) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Proportion of individuals") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 2 5 6) lab(1 "Positive infinite; high") lab(2 "Negative infinite; low") lab(5 "Positive infinite; male") lab(6 "Negative infinite; male")) ylabel(0(0.01)0.03);
#delimit cr
graph export "$G/inf_sugar_adds_class.png",replace

#delimit ;
scatter coef_sugar asgrp if hcl==1,mc(black)||
line    coef_sugar asgrp if hcl==1,lc(black) lpattern(shortdash)||
scatter coef_sugar asgrp if hcl==0,mc(black) ms(Oh)||
line    coef_sugar asgrp if hcl==0,lc(black) lpattern(dash)
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 3) lab(1 "High") lab(3 "Low")) ylabel(-0.5(0.5)1.5);
#delimit cr
graph export "$G/sugar_coef_adds_class.png",replace

#delimit ;
scatter coef_price asgrp if hcl==1,mc(black)||
line    coef_price asgrp if hcl==1,lc(black) lpattern(shortdash) ||
scatter coef_price asgrp if hcl==0,mc(black) ms(Oh)||
line    coef_price asgrp if hcl==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 3) lab(1 "High") lab(3 "Low"))  ylabel(-4(0.5)-2);
#delimit cr
graph export "$G/price_coef_adds_class.png",replace

#delimit ;
scatter coef_drink asgrp if hcl==1,mc(black)||
line    coef_drink asgrp if hcl==1,lc(black) lpattern(shortdash) ||
scatter coef_drink asgrp if hcl==0,mc(black) ms(Oh)||
line    coef_drinks asgrp if hcl==0,lc(black) lpattern(dash) 
graphr(color(white))  bgcolor(white)  ytitle("Drinks preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 3) lab(1 "High") lab(3 "Low")) ylabel(2(0.5)4);
#delimit cr
graph export "$G/drinks_coef_adds_class.png",replace

**********************
**Jackknife addiitonal graphs
**********************

u "$O/Jackknife/Jackknife_results.dta",clear

**************
**Table B.6
**************

centile diff2_price,centile(1 99)
lpoly diff2_price T if diff2_price<r(c_2)&diff2_price>r(c_1) & n==1, ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("T") ytitle("Difference") title("") note("")
graph export "$G/price_T.png",replace

centile diff2_drinks,centile(1 99)
lpoly diff2_drinks T if diff2_drinks<r(c_2)&diff2_drinks>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("T") ytitle("Difference") title("") note("")
graph export "$G/drinks_T.png",replace

centile diff2_sugary,centile(1 99)
lpoly diff2_sugary T if diff2_sugary<r(c_2)&diff2_sugary>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("T") ytitle("Difference") title("") ylabel(-.6(.2).6) note("")
graph export "$G/sugar_T.png",replace

**************
**Table B.7
**************

centile diff2_price,centile(1 99)
lpoly diff2_price annexp_eq  if annexp_eq<cu2_annexp_eq & annexp_eq>cl2_annexp_eq & diff2_price<r(c_2)&diff2_price>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("Total equivalized grocery expenditure") ytitle("Difference") title("") note("")
graph export "$G/price_exp.png",replace
centile diff2_drinks,centile(1 99)
lpoly diff2_drinks  annexp_eq  if annexp_eq<cu2_annexp_eq & annexp_eq>cl2_annexp_eq & diff2_drinks<r(c_2)&diff2_drinks>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("Total equivalized grocery expenditure") ytitle("Difference") title("") note("") 
graph export "$G/drinks_exp.png",replace
centile diff2_sugary,centile(1 99)
lpoly diff2_sugar annexp_eq  if annexp_eq<cu2_annexp_eq & annexp_eq>cl2_annexp_eq & diff2_sugary<r(c_2)&diff2_sugary>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("Total equivalized grocery expenditure") ytitle("Difference") title("") note("")
graph export "$G/sugar_exp.png",replace

centile diff2_price,centile(1 99)
lpoly diff2_price annaddsr  if annaddsr<cu2_annaddsr & annaddsr>cl2_annaddsr & diff2_price<r(c_2)&diff2_price>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("% of calories from added sugar in total grocery basket") ytitle("Difference") title("") note("")
graph export "$G/price_sug.png",replace
centile diff2_drinks,centile(1 99)
lpoly diff2_drinks  annaddsr  if annaddsr<cu2_annaddsr & annaddsr>cl2_annaddsr & diff2_drinks<r(c_2)&diff2_drinks>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("% of calories from added sugar in total grocery basket") ytitle("Difference") title("") note("") 
graph export "$G/drinks_sug.png",replace
centile diff2_sugary,centile(1 99)
lpoly diff2_sugar annaddsr  if annaddsr<cu2_annaddsr & annaddsr>cl2_annaddsr & diff2_sugary<r(c_2)&diff2_sugary>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("% of calories from added sugar in total grocery basket") ytitle("Difference") title("") note("")
graph export "$G/sugar_sug.png",replace

centile diff2_price,centile(1 99)
lpoly diff2_price age  if age<65 & diff2_price<r(c_2)&diff2_price>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("Age") ytitle("Difference") title("") note("")
graph export "$G/price_age.png",replace
centile diff2_drinks,centile(1 99)
lpoly diff2_drinks  age  if age<65 & diff2_drinks<r(c_2)&diff2_drinks>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("Age") ytitle("Difference") title("") note("") 
graph export "$G/drinks_age.png",replace
centile diff2_sugary,centile(1 99)
lpoly diff2_sugar age  if age<65 & diff2_sugary<r(c_2)&diff2_sugary>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("Age") ytitle("Difference") title("") note("")
graph export "$G/sugar_age.png",replace

**************
**Table B.8
**************

centile S3_coef_price,centile(2.5 97.5)
gen l1 = r(c_1)
gen u1 = r(c_2)
centile correction_price,centile(2.5 97.5)
gen l2 = r(c_1)
gen u2 = r(c_2)
kdensity S3_coef_price    if S3_coef_price>l1&S3_coef_price<u1,gen(x1 y1)
kdensity correction_price if correction_price>l2&correction_price<u2,gen(x2 y2)
line y1 x1,lcolor(black) lpattern(solid) || line y2 x2,lcolor(black) lpattern(dash) graphr(color(white)) bgcolor(white) xtitle("Price preference parameter") ytitle("Density") title("") legend(lab(1 "ML estimate") lab(2 "Corrected estimate"))
graph export "$G/price_cor_dist.png",replace
drop x1 y1 x2 y2 l1 u1 l2 u2

centile S3_coef_drinks,centile(1 99)
gen l1 = r(c_1)
gen u1 = r(c_2)
centile correction_drinks,centile(1 99)
gen l2 = r(c_1)
gen u2 = r(c_2)
kdensity S3_coef_drinks    if S3_coef_drinks>l1&S3_coef_drinks<u1,gen(x1 y1)
kdensity correction_drinks if correction_drinks>l2&correction_drinks<u2,gen(x2 y2)
line y1 x1,lcolor(black) lpattern(solid) || line y2 x2,lcolor(black) lpattern(dash) graphr(color(white)) bgcolor(white) xtitle("drinks preference parameter") ytitle("Density") title("") legend(lab(1 "ML estimate") lab(2 "Corrected estimate"))
graph export "$G/drinks_cor_dist.png",replace
drop x1 y1 x2 y2 l1 u1 l2 u2

centile S3_coef_sugary,centile(1 99)
gen l1 = r(c_1)
gen u1 = r(c_2)
centile correction_sugary,centile(1 99)
gen l2 = r(c_1)
gen u2 = r(c_2)
kdensity S3_coef_sugary    if S3_coef_sugary>l1&S3_coef_sugary<u1,gen(x1 y1)
kdensity correction_sugary if correction_sugary>l2&correction_sugary<u2,gen(x2 y2)
line y1 x1,lcolor(black) lpattern(solid) || line y2 x2,lcolor(black) lpattern(dash) graphr(color(white)) bgcolor(white) xtitle("Sugar preference parameter") ytitle("Density") title("") legend(lab(1 "ML estimate") lab(2 "Corrected estimate"))
graph export "$G/sugar_cor_dist.png",replace
drop x1 y1 x2 y2 l1 u1 l2 u2


*******************************
**at-home - data
*******************************

**********
**Table C.1
**********

u "$P2/Tdimstats.dta",clear

listtab group i1 perc1 using "$G/indv_inT1.tex", replace rstyle(tabular)

gen tot = 1

collapse (sum) i1 perc1,by(tot)

lab def tot 1 "Total"
lab val tot tot

listtab tot i1 perc1 using "$G/indv_inT2.tex", replace rstyle(tabular)

**********
**Table C.2
**********

u "$P2/productstats_in.dta",clear

forv b = 1/10 {
	listtab o o product share price using "$G/products_in`b'p.tex" if brand==`b', replace rstyle(tabular)
}
listtab o o product share price using "$G/products_in100p.tex" if brand==100, replace rstyle(tabular)
listtab o brand o share price using "$G/products_in110p.tex" if brand==110, replace rstyle(tabular)
listtab o brand o share price using "$G/products_in120p.tex" if brand==120, replace rstyle(tabular)
listtab o brand o share price using "$G/products_in130p.tex" if brand==130, replace rstyle(tabular)
listtab o brand o share price using "$G/products_in140p.tex" if brand==140, replace rstyle(tabular)

collapse (sum) share,by(brand firm o)

forv b = 1/10 {
	listtab o brand o share o using "$G/products_in`b'b.tex" if brand==`b', replace rstyle(tabular)
}

collapse (sum) share,by(firm o)

forv b = 1/4 {
	listtab firm o o share o using "$G/products_in`b'f.tex" if firm==`b', replace rstyle(tabular)
}


**********
**Table C.3
**********

u "$P2/storestats_in.dta",clear

listtab store store2 i0 share using "$G/stores_in.tex", replace rstyle(tabular)

collapse (sum) i0 share

gen tot = 1
lab def tot 1 "Total"
lab val tot tot
gen o=""

format %9.0fc i0

listtab tot o i0 share using "$G/stores2_in.tex", replace rstyle(tabular)


*******************************
**at-home - estimates
*******************************

**********
**Table C.4
**********
u "$P/coefficients_in1.dta",clear

format coef se %9.4f

listtab vr var coef se using "$G/pricecoef_in.tex"  if vr<5,rstyle(tabular)  replace
listtab vr var coef se using "$G/drinkscoef_in.tex" if vr>4&vr<9 ,rstyle(tabular)  replace
listtab vr var coef se using "$G/sugarcoef_in.tex"  if vr>8&vr<13,rstyle(tabular)  replace
listtab vr var coef se using "$G/covcoef_in.tex"    if vr>12&vr<16,rstyle(tabular)  replace

u "$P/coefficients_in2.dta",clear

format coef se %9.4f

listtab vr gp coef se using "$G/fixedcoef1_in.tex"  if n==1,rstyle(tabular)  replace
listtab vr gp coef se using "$G/fixedcoef2_in.tex"  if n==2,rstyle(tabular)  replace
listtab vr gp coef se using "$G/fixedcoef3_in.tex"  if n==3,rstyle(tabular)  replace
listtab vr gp coef se using "$G/fixedcoef4_in.tex"  if n==4,rstyle(tabular)  replace
listtab vr gp coef se using "$G/fixedcoef5_in.tex"  if n==5,rstyle(tabular)  replace


u "$P2/purchyearfull.dta",clear

bysort hhno year: keep if _n==1
keep hhno year annaddsr annexp_eq asgrp eegrp

sa "$D/hhyearpurch_base_in.dta",replace


u "$P2/purchyearfull.dta",clear

gen hcl = class<3

collapse (sum) sodaN,by(hhno year agecat asgrp eegrp hcl)

replace sodaN = int(sodaN+0.5)
 
keep hhno year agecat asgrp eegrp hcl sodaN

expand sodaN
sort hhno  year  

foreach v in agecat asgrp eegrp hcl{
	egen `v'_m = mode(`v'),by(hhno) minmode
}
bysort hhno: keep if _n==1
su hhno agecat_m asgrp_m eegrp_m hcl_m

keep hhno agecat_m asgrp_m eegrp_m hcl_m

foreach v in agecat asgrp eegrp hcl {
	rename `v'_m `v'
}

sa "$D/hhpurch_base_in.dta",replace

***************
**Figure C.1(a)-(b)
***************

***By dietary sugar

u "$D/hhpurch_base_in.dta",clear

merge 1:1 hhno using "$P/FoodIn/coefs_consumer.dta"
keep if _m==3
drop _m

collapse (mean) coef_sugary coef_price,by(asgrp)

#delimit ;
scatter coef_sugary asgrp, mc(black)
|| line coef_sugary asgrp, lc(black) lpattern(shortdash)
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(off) ylabel(-1.5(0.5)0.5);
#delimit cr
graph export "$G/sugar_coef_in_adds.png",replace

#delimit ;
scatter coef_price asgrp, mc(black)
|| line coef_price asgrp, lc(black) lpattern(shortdash)
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(off) ylabel(-3(0.2)-2);
#delimit cr
graph export "$G/price_coef_in_adds.png",replace

***************
**Figure C.1(c)-(d)
***************

***By equivalized expenditure

u "$D/hhyearpurch_base_in.dta",clear

merge m:1 hhno using "$P/FoodIn/coefs_consumer.dta"
keep if _m==3
drop _m

collapse (mean) coef_sugary coef_price,by(eegrp)

#delimit ;
scatter coef_sugary eegrp, mc(black)
|| line coef_sugary eegrp, lc(black) lpattern(shortdash)
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(off)  ylabel(-1.5(0.5)0.5);
#delimit cr
graph export "$G/sugar_coef_in_eexp.png",replace

#delimit ;
scatter coef_price eegrp, mc(black)
|| line coef_price eegrp, lc(black) lpattern(shortdash)
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(off) ylabel(-3(0.2)-2);
#delimit cr
graph export "$G/price_coef_in_eexp.png",replace


