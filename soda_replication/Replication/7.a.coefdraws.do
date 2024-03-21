global O  "$nhp"
global P  "$rs"

insheet using "$O/pdraw.raw",clear

gen dm = _n
drop v101

merge 1:1 dm using "$P/dropindex.dta"
drop _m 

drop if dp==1
drop group indrink coef_sugary coef_drinks dp

order dm

sa "$P/MonteCarlo/pdraw.dta",replace

u "$P/dropindex.dta",clear

keep if indrink==1

gen n = _n

sa "$P/MonteCarlo/soda_dm.dta",replace

insheet using "$O/xdraw.raw",clear

gen n = _n
drop v101

merge 1:1 n using "$P/MonteCarlo/soda_dm.dta"
drop _m n

drop if dp==1
drop group indrink coef_sugary coef_drinks dp
order dm

sa "$P/MonteCarlo/xdraw.dta",replace

u "$P/dropindex.dta",clear

keep if coef_sugar!=.

gen n = _n

sa "$P/MonteCarlo/sugar_dm.dta",replace

insheet using "$O/ydraw.raw",clear

gen n = _n
drop v101

merge 1:1 n using "$P/MonteCarlo/sugar_dm.dta"
drop _m n

drop if dp==1
drop group indrink coef_sugary coef_drinks dp
order dm

sa "$P/MonteCarlo/ydraw.dta",replace

insheet using "$O/fdraw.raw",clear

drop v101

gen     group = 1 if _n<23
replace group = 2 if _n>22&_n<45
replace group = 3 if _n>44&_n<67
replace group = 4 if _n>66

gen     fcoef = 1  if _n==1 |_n==23|_n==45|_n==67
replace fcoef = 2  if _n==2 |_n==24|_n==46|_n==68
replace fcoef = 3  if _n==3 |_n==25|_n==47|_n==69
replace fcoef = 4  if _n==4 |_n==26|_n==48|_n==70
replace fcoef = 5  if _n==5 |_n==27|_n==49|_n==71
replace fcoef = 6  if _n==6 |_n==28|_n==50|_n==72
replace fcoef = 7  if _n==7 |_n==29|_n==51|_n==73
replace fcoef = 8  if _n==8 |_n==30|_n==52|_n==74
replace fcoef = 9  if _n==9 |_n==31|_n==53|_n==75
replace fcoef = 10 if _n==10|_n==32|_n==54|_n==76
replace fcoef = 11 if _n==11|_n==33|_n==55|_n==77
replace fcoef = 12 if _n==12|_n==34|_n==56|_n==78
replace fcoef = 13 if _n==13|_n==35|_n==57|_n==79
replace fcoef = 14 if _n==14|_n==36|_n==58|_n==80
replace fcoef = 15 if _n==15|_n==37|_n==59|_n==81
replace fcoef = 16 if _n==16|_n==38|_n==60|_n==82
replace fcoef = 17 if _n==17|_n==39|_n==61|_n==83
replace fcoef = 18 if _n==18|_n==40|_n==62|_n==84
replace fcoef = 19 if _n==19|_n==41|_n==63|_n==85
replace fcoef = 20 if _n==20|_n==42|_n==64|_n==86
replace fcoef = 21 if _n==21|_n==43|_n==65|_n==87
replace fcoef = 22 if _n==22|_n==44|_n==66|_n==88

order group fcoef

sa "$P/MonteCarlo/fdraw.dta",replace

insheet using "$O/adraw.raw",clear

rename v1 group
rename v2 brd
rename v3 year
drop v104
foreach n of numlist 1(1)100 {
    local l = `n'+3
    rename v`l' v`n'
}

sa "$P/MonteCarlo/adraw.dta",replace

insheet using "$O/qdraw.raw",clear

rename v1 group
rename v2 brd
rename v3 quarter
drop v104
foreach n of numlist 1(1)100 {
    local l = `n'+3
    rename v`l' v`n'
}

sa "$P/MonteCarlo/qdraw.dta",replace

insheet using "$O/rdraw.raw",clear

rename v1 group
rename v2 out
rename v3 rm
drop v104
foreach n of numlist 1(1)100 {
    local l = `n'+3
    rename v`l' v`n'
}

sa "$P/MonteCarlo/rdraw.dta",replace


