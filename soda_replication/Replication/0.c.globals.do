
global Avars = "price drinks sugary inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside"
global Bvars = "price drinks    	inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside"
global Cvars = "price drinks	    inv size288 size330 size380 adstock drinkstmax drpepper fanta cherry oasis pepsi lucenergy ribena sprite irnbru other fruit milk fruitwater water sugoutside"
global rvars = "other fruit water sugoutside nonoutside"
global tvars = "coke cokeoth pepsico gsk barr othsoda othsug water sugoutside"
global g "1.6"
global UK_tau "0.25"
global US_tau "0.25"
global BR "100"

cap prog drop predictshr
prog def predictshr 
	gen V = 0
	foreach v in $Avars {
		qui replace V = V+`v'*coef_`v' if order==1
	}
	foreach v in $Bvars {
		qui replace V = V+`v'*coef_`v' if order==2
	}
	foreach v in $Cvars {
		qui replace V = V+`v'*coef_`v' if order==3
	}
	foreach v in $rvars {
		qui replace V = V+`v'*coef_`v'_r
	}
	foreach v in $tvars {
		qui replace V = V+`v'*coef_`v'_y+`v'*coef_`v'_q
	}
	gen eV=exp(V)
	egen den = sum(eV),by(csindex)
	gen prob = eV/den
	drop eV den
end