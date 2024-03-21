
global P2 "$ds"
global P  "$rs"
global O  "$nhp"

global G  "$rr"
global Gj "$jr"


*****************************************************
**Coefficient distributions
*****************************************************

**********
**Figure 1
**********

clear
set obs 200
gen p = 1+0.25*(_n-1)
replace p = p-25
sa "$P/soft_app.dta",replace

u "$P/coefs_consumer.dta",clear

su coef_price
local l = r(N)

gen p = round(coef_price,0.25)

gen p1 = 0
replace p1 = 1 if z_price<=-1.96
gen p2 = 0
replace p2 = 1 if z_price>-1.96&z_price<1.96
gen p3 = 0
replace p3 = 1 if z_price>=1.96

collapse (sum) p1 p2 p3,by(p)

merge 1:1 p using "$P/soft_app.dta"
drop _m
drop if p<-15|p>5

replace p1 = 0 if p1==.
replace p2 = 0 if p2==.
replace p3 = 0 if p3==.

foreach n of numlist 1(1)3 {
    replace p`n' = p`n'/`l'
}	

gen p1_p2 = (p1 + p2)
gen p2_p3 = (p2 + p3)
gen p1_p2_p3 = (p1 + p2 + p3)
gen p1_p3 = (p1 + p3)

#delimit ;
twoway bar  p2 p, barw(0.25)  lcolor(black) fcolor(gs10)
||  rbar  p2 p1_p2 p, barw(0.25)  lcolor(black) fcolor(black)
||  rbar  p2 p2_p3 p, barw(0.25) lcolor(black) fcolor(gs4) 
legend(off) graphr(color(white)) bgcolor(white)
legend(off) graphr(color(white)) bgcolor(white)
xtitle("Price coefficient") ytitle("Fraction of individuals")
;
#delimit cr			
graph export "$G/price_coef_dist.pdf",replace

u "$P/coefs_consumer.dta",clear

keep if indrink==1

su coef_drinks
local l = r(N)

gen p = round(coef_drinks,0.25)

gen p1 = 0
replace p1 = 1 if z_drinks<=-1.96
gen p2 = 0
replace p2 = 1 if z_drinks>-1.96&z_drinks<1.96
gen p3 = 0
replace p3 = 1 if z_drinks>=1.96&z_drinks<.

replace p = 15 if p==.
replace p3 = 1 if p==15

collapse (sum) p1 p2 p3,by(p)

merge 1:1 p using "$P/soft_app.dta"
drop _m
drop if p>15
drop if p<-4

replace p1 = 0 if p1==.
replace p2 = 0 if p2==.
replace p3 = 0 if p3==.

foreach n of numlist 1(1)3 {
    replace p`n' = p`n'/`l'
}

gen p1_p2 = (p1 + p2)
gen p2_p3 = (p2 + p3)
gen p1_p2_p3 = (p1 + p2 + p3)
gen p1_p3 = (p1 + p3)

#delimit ;
twoway bar  p2 p, barw(0.25)  lcolor(black) fcolor(gs10)
||  rbar  p2 p1_p2 p, barw(0.25)  lcolor(black) fcolor(black)
||  rbar  p2 p2_p3 p, barw(0.25) lcolor(black) fcolor(gs4) 
legend(off) graphr(color(white)) bgcolor(white)
xtitle("Drinks coefficient") ytitle("Fraction of individuals")
;
#delimit cr			
graph export "$G/drinks_coef_dist.pdf",replace

u "$P/coefs_consumer.dta",clear

su coef_sugary
local l = r(N)

gen p = round(coef_sugar,0.25)

gen p1 = 0
replace p1 = 1 if z_sugar<=-1.96
gen p2 = 0
replace p2 = 1 if z_sugar>-1.96&z_sugar<1.96
gen p3 = 0
replace p3 = 1 if z_sugar>=1.96&z_sugar<.

replace p  = -12 if sugar_prev==2
replace p1 = 1 if p==-12
replace p  = 12 if sugar_prev==1
replace p3 = 1 if p==12

collapse (sum) p1 p2 p3,by(p)

merge 1:1 p using  "$P/soft_app.dta"
drop _m
drop if p>12|p<-12

replace p1 = 0 if p1==.
replace p2 = 0 if p2==.
replace p3 = 0 if p3==.

foreach n of numlist 1(1)3 {
    replace p`n' = p`n'/`l'
}

gen p1_p2 = (p1 + p2)
gen p2_p3 = (p2 + p3)
gen p1_p2_p3 = (p1 + p2 + p3)
gen p1_p3 = (p1 + p3)

#delimit ;
twoway bar  p2 p, barw(0.25)  lcolor(black) fcolor(gs10)
||  rbar  p2 p1_p2 p, barw(0.25)  lcolor(black) fcolor(black)
||  rbar  p2 p2_p3 p, barw(0.25) lcolor(black) fcolor(gs4) 
legend(off) graphr(color(white)) bgcolor(white)
xtitle("Sugar coefficient") ytitle("Fraction of individuals")
;
#delimit cr			
graph export "$G/sugar_coef_dist.png",replace

graph bar (sum) p2 p1 p3, over(p) stack bar(2,color(black)) bar(1,color(gs10)) bar(3,color(gs4)) graphr(color(white)) bgcolor(white) legend(lab(1 "Indifferent" "(not statistically different from zero)") lab(2 "Negative") lab(3 "Positive") order(2 1 3) rows(3) size(large)) ytitle(Density)
graph export "$G/legend.png",replace


*****************************************************
**Coefficients by demographics
*****************************************************

**********
**Figure 2
**********

***By age

u "$P/coefageresults.dta",clear

#delimit ;
scatter coef_price agecat, mc(black)
|| line coef_price agecat, lc(black) lpattern(shortdash)
|| rcap lb_coef_price ub_coef_price agecat, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age")
legend(off) ylabel(-4(0.5)-2);
#delimit cr
graph export "$G/price_coef_age.pdf",replace

#delimit ;
scatter coef_drinks agecat, mc(black)
|| line coef_drinks agecat, lc(black) lpattern(shortdash)
|| rcap lb_coef_drinks ub_coef_drinks agecat, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Drinks preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age")
legend(off) ylabel(2(0.5)4);
#delimit cr
graph export "$G/drinks_coef_age.pdf",replace

#delimit ;
scatter sugpinf sugninf agecat,mc(black gs8) ||
line    sugpinf agecat,lc(black) lpattern(shortdash) ||
line    sugninf agecat,lc(gs8) lpattern(shortdash)
graphr(color(white))  bgcolor(white)  ytitle("Proportion of individuals") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 2) lab(1 "Positive infinite") lab(2 "Negative infinite")) ylabel(0(0.01)0.03);
#delimit cr
graph export "$G/inf_sugar_age.pdf",replace

#delimit ;
scatter coef_sugary agecat, mc(black)
|| line coef_sugary agecat, lc(black) lpattern(shortdash)
|| rcap lb_coef_sugary ub_coef_sugary agecat, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age")
legend(off) ylabel(-0.5(0.5)1.5);
#delimit cr
graph export "$G/sugar_coef_age.pdf",replace

**********
**Figure 3
**********

***By dietary sugar

u "$P/coefaddsugresults.dta",clear

#delimit ;
scatter coef_price asgrp, mc(black)
|| line coef_price asgrp, lc(black) lpattern(shortdash)
|| rcap lb_coef_price ub_coef_price asgrp, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(off)  ylabel(-4(0.5)-2);
#delimit cr
graph export "$G/price_coef_adds.pdf",replace

#delimit ;
scatter coef_drinks asgrp, mc(black)
|| line coef_drinks asgrp, lc(black) lpattern(shortdash)
|| rcap lb_coef_drinks ub_coef_drinks asgrp, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Drinks preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(off) ylabel(2(0.5)4);
#delimit cr
graph export "$G/drinks_coef_adds.pdf",replace

#delimit ;
scatter sugpinf sugninf asgrp,mc(black gs8) ||
line    sugpinf asgrp,lc(black) lpattern(shortdash) ||
line    sugninf asgrp,lc(gs8) lpattern(shortdash)
graphr(color(white))  bgcolor(white)  ytitle("Proportion of individuals") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 2) lab(1 "Positive infinite") lab(2 "Negative infinite")) ylabel(0(0.01)0.03);
#delimit cr
graph export "$G/inf_sugar_adds.pdf",replace

#delimit ;
scatter coef_sugary asgrp, mc(black)
|| line coef_sugary asgrp, lc(black) lpattern(shortdash)
|| rcap lb_coef_sugary ub_coef_sugary asgrp, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(off)ylabel(-0.5(0.5)1.5);
#delimit cr
graph export "$G/sugar_coef_adds.pdf",replace

**********
**Figure 4
**********

***By equivalized expenditure

u "$P/coefexpresults.dta",clear

#delimit ;
scatter coef_price eegrp, mc(black)
|| line coef_price eegrp, lc(black) lpattern(shortdash)
|| rcap lb_coef_price ub_coef_price eegrp, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Price preference parameter") title("")  xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(off)  ylabel(-4(0.5)-2);
#delimit cr
graph export "$G/price_coef_eexp.pdf",replace

#delimit ;
scatter coef_drinks eegrp, mc(black)
|| line coef_drinks eegrp, lc(black) lpattern(shortdash)
|| rcap lb_coef_drinks ub_coef_drinks eegrp, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Drinks preference parameter") title("")  xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(off) ylabel(2(0.5)4);
#delimit cr
graph export "$G/drinks_coef_eexp.pdf",replace

#delimit ;
scatter sugpinf sugninf eegrp,mc(black gs8) ||
line    sugpinf eegrp,lc(black) lpattern(shortdash) ||
line    sugninf eegrp,lc(gs8) lpattern(shortdash)
graphr(color(white))  bgcolor(white)  ytitle("Proportion of individuals") title("")  xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(order(1 2) lab(1 "Positive infinite") lab(2 "Negative infinite")) ylabel(0(0.01)0.03);
#delimit cr
graph export "$G/inf_sugar_eexp.pdf",replace

#delimit ;
scatter coef_sugary eegrp, mc(black)
|| line coef_sugary eegrp, lc(black) lpattern(shortdash)
|| rcap lb_coef_sugary ub_coef_sugary eegrp, color(black) 
graphr(color(white))  bgcolor(white)  ytitle("Sugar preference parameter") title("")  xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(off)ylabel(-0.5(0.5)1.5);
#delimit cr
graph export "$G/sugar_coef_eexp.pdf",replace

********************************************************************************
**Counterfactual predictions 
********************************************************************************

****************************
**Figure 5 and Figure 6 panel (a)
****************************

***Age

u "$P/taxageresults.dta",clear

cap drop temp*
gen temp = agecat + 0.05
gen temp2 = agecat + 0.1

#delimit ;
scatter diff_UK_soda_sug agecat,mc(gs10)||
scatter diff_UK_drk_sug  temp,mc(gs6)||
scatter diff_UK_tot_sug  temp2,mc(black)||
line    diff_UK_soda_sug agecat,lc(gs10) lpattern(shortdash) ||
line    diff_UK_drk_sug  temp,lc(gs6) lpattern(shortdash) ||
line    diff_UK_tot_sug  temp2,lc(black) lpattern(shortdash) ||
rcap    lb_diff_UK_soda_sug ub_diff_UK_soda_sug agecat,lc(gs10) ||
rcap    lb_diff_UK_drk_sug ub_diff_UK_drk_sug temp,lc(gs6) ||
rcap    lb_diff_UK_tot_sug ub_diff_UK_tot_sug temp2,lc(black)
graphr(color(white))  bgcolor(white)  ytitle("Reduction in sugar (g)") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 2 3) lab(1 "Sugar from soft drinks") lab(2 "Sugar from non-alcoholic drinks") lab(3 "Total sugar")) ylabel(0(50)350);
#delimit cr
graph export "$G/sug_UK_age.pdf",replace

#delimit ;
scatter UK_CV agecat,mc(black)||
line    UK_CV agecat,lc(black) lpattern(shortdash) ||
rcap    lb_UK_CV ub_UK_CV agecat,lc(black) 
graphr(color(white))  bgcolor(white)  ytitle("Compensating variation (£)")title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(off) ylabel(0(1)5);
#delimit cr
graph export "$G/CV_UK_age.pdf",replace


****************************
**Figure 5 and Figure 6 panel (b)
****************************

***Dietary sugar
u "$P/taxaddsugresults.dta",clear

cap drop temp*
gen temp = asgrp + 0.05
gen temp2 = asgrp + 0.1

#delimit ;
scatter diff_UK_soda_sug asgrp,mc(gs10)||
scatter diff_UK_drk_sug  temp,mc(gs6)||
scatter diff_UK_tot_sug  temp2,mc(black)||
line    diff_UK_soda_sug asgrp,lc(gs10) lpattern(shortdash) ||
line    diff_UK_drk_sug  temp,lc(gs6) lpattern(shortdash) ||
line    diff_UK_tot_sug  temp2,lc(black) lpattern(shortdash) ||
rcap    lb_diff_UK_soda_sug ub_diff_UK_soda_sug asgrp,lc(gs10) ||
rcap    lb_diff_UK_drk_sug ub_diff_UK_drk_sug temp,lc(gs6) ||
rcap    lb_diff_UK_tot_sug ub_diff_UK_tot_sug temp2,lc(black)
graphr(color(white))  bgcolor(white)  ytitle("Reduction in sugar (g)") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar") 
legend(order(1 2 3) lab(1 "Sugar from soft drinks") lab(2 "Sugar from non-alcoholic drinks") lab(3 "Total sugar")) ylabel(0(50)350);
#delimit cr
graph export "$G/sug_UK_adds.pdf",replace

#delimit ;
scatter UK_CV asgrp,mc(black)||
line    UK_CV asgrp,lc(black) lpattern(shortdash) ||
rcap    lb_UK_CV ub_UK_CV asgrp,lc(black) 
graphr(color(white))  bgcolor(white)  ytitle("Compensating variation (£)")title("")  xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar") 
legend(off) ylabel(0(1)5);
#delimit cr
graph export "$G/CV_UK_adds.pdf",replace

****************************
**Figure 5 and Figure 6 panel (c)
****************************
***Equivalized expenditure
u "$P/taxexpresults.dta",clear

cap drop temp*
gen temp = eegrp + 0.05
gen temp2 = eegrp + 0.1

#delimit ;
scatter diff_UK_soda_sug eegrp,mc(gs10)||
scatter diff_UK_drk_sug  temp,mc(gs6)||
scatter diff_UK_tot_sug  temp2,mc(black)||
line    diff_UK_soda_sug eegrp,lc(gs10) lpattern(shortdash) ||
line    diff_UK_drk_sug  temp,lc(gs6) lpattern(shortdash) ||
line    diff_UK_tot_sug  temp2,lc(black) lpattern(shortdash) ||
rcap    lb_diff_UK_soda_sug ub_diff_UK_soda_sug eegrp,lc(gs10) ||
rcap    lb_diff_UK_drk_sug ub_diff_UK_drk_sug temp,lc(gs6) ||
rcap    lb_diff_UK_tot_sug ub_diff_UK_tot_sug temp2,lc(black)
graphr(color(white))  bgcolor(white)  ytitle("Reduction in sugar (g)") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(order(1 2 3) lab(1 "Sugar from soft drinks") lab(2 "Sugar from non-alcoholic drinks") lab(3 "Total sugar")) ylabel(0(50)350);
#delimit cr
graph export "$G/sug_UK_eexp.pdf",replace

#delimit ;
scatter UK_CV eegrp,mc(black)||
line    UK_CV eegrp,lc(black) lpattern(shortdash) ||
rcap    lb_UK_CV ub_UK_CV eegrp,lc(black) 
graphr(color(white))  bgcolor(white)  ytitle("Compensating variation (£)")title("")  xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(off) ylabel(0(1)5);
#delimit cr
graph export "$G/CV_UK_eexp.pdf",replace



********************************************************************************
***Robustness
********************************************************************************

**********
**Figure 7
**********

u "$O/Jackknife/Jackknife_results.dta",clear

centile S3_coef_sugary,centile(1 99)
gen l1 = r(c_1)
gen u1 = r(c_2)
centile correction_sugary,centile(1 99)
gen l2 = r(c_1)
gen u2 = r(c_2)
kdensity S3_coef_sugary    if S3_coef_sugary>l1&S3_coef_sugary<u1,gen(x1 y1)
kdensity correction_sugary if correction_sugary>l2&correction_sugary<u2,gen(x2 y2)
line y1 x1,lcolor(black) lpattern(solid) || line y2 x2,lcolor(black) lpattern(dash) graphr(color(white)) bgcolor(white) xtitle("Sugar preference parameter") ytitle("Density") title("") legend(lab(1 "ML estimate") lab(2 "Corrected estimate"))
graph export "$Gj/sugar_cor_dist.pdf",replace
drop x1 y1 x2 y2 l1 u1 l2 u2

centile diff2_sugary,centile(1 99)
lpoly diff2_sugary T if diff2_sugary<r(c_2)&diff2_sugary>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("T") ytitle("Difference") title("") ylabel(-.6(.2).6) note("")
graph export "$Gj/sugar_T.pdf",replace

centile diff2_sugary,centile(1 99)
lpoly diff2_sugar age  if age<65 & diff2_sugary<r(c_2)&diff2_sugary>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("Age") ytitle("Difference") title("") note("")
graph export "$Gj/sugar_age.pdf",replace

centile diff2_sugary,centile(1 99)
lpoly diff2_sugar annaddsr  if annaddsr<cu2_annaddsr & annaddsr>cl2_annaddsr & diff2_sugary<r(c_2)&diff2_sugary>r(c_1), ylabel(-1(0.5)1) msymbol(+) mcolor(gs12) bwidth() lineop(lcolor(black)) graphr(color(white)) bgcolor(white) xtitle("% of calories from added sugar in total grocery basket") ytitle("Difference") title("") note("")
graph export "$Gj/sugar_sug.pdf",replace

**********
**Figure 8
**********

u "$P/athome_age.dta",replace

scatter delta_in delta_out agecat,mc(gs8 black) || line delta_in delta_out agecat,lc(gs8 black) lpattern(shortdash shortdash) legend(order(2 1) lab(2 "On-the-go") lab(1 "At-home")) xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") ytitle("Impact of tax on sugar from drinks" "relative to age <22")
graph export "$G/at_home_age.pdf",replace

**********
**Figure 9
**********

u "$P/passageresults.dta",clear

#delimit ;
scatter diff_UK_tot_sug diff_UK_tot_sug_eq agecat,mc(gs10 black)||
line    diff_UK_tot_sug    agecat,lc(gs10) lpattern(shortdash) ||
line    diff_UK_tot_sug_eq agecat,lc(black) lpattern(shortdash) 
graphr(color(white))  bgcolor(white)  ytitle("Reduction in sugar (g)") title("") xlabel(1 "<22" 2 "22-30" 3 "31-40" 4 "41-50" 5 "51-60" 6 "60+") xtitle("Age") 
legend(order(1 2) lab(1 "100% pass-through") lab(2 "Equilibrium pass-through")) ylabel(0(50)350);
#delimit cr
graph export "$G/sug_UK_age_pass.pdf",replace


u "$P/passaddsugresults.dta",clear

#delimit ;
scatter diff_UK_tot_sug diff_UK_tot_sug_eq asgrp,mc(gs10 black)||
line    diff_UK_tot_sug    asgrp,lc(gs10) lpattern(shortdash) ||
line    diff_UK_tot_sug_eq asgrp,lc(black) lpattern(shortdash) 
graphr(color(white))  bgcolor(white)  ytitle("Reduction in sugar (g)") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "share of calories from added sugar")
legend(order(1 2) lab(1 "100% pass-through") lab(2 "Equilibrium pass-through")) ylabel(0(50)350);
#delimit cr
graph export "$G/sug_UK_adds_pass.pdf",replace


u "$P/passexpresults.dta",clear

#delimit ;
scatter diff_UK_tot_sug diff_UK_tot_sug_eq eegrp,mc(gs10 black)||
line    diff_UK_tot_sug    eegrp,lc(gs10) lpattern(shortdash) ||
line    diff_UK_tot_sug_eq eegrp,lc(black) lpattern(shortdash) 
graphr(color(white))  bgcolor(white)  ytitle("Reduction in sugar (g)") title("") xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") xtitle("Decile of distribution of" "total equivalized grocery expenditure")
legend(order(1 2) lab(1 "100% pass-through") lab(2 "Equilibrium pass-through")) ylabel(0(50)350);
#delimit cr
graph export "$G/sug_UK_eexp_pass.pdf",replace
