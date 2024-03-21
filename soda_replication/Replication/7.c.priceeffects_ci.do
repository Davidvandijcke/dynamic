global P  "$rs"

u "$P/MonteCarlo/$N/log_coef.dta",clear

gen price_base=price
predictshr
rename prob prob_base
drop V

foreach n of numlist 1(1)32 110 120 130 140 {
    qui replace price=price_base
    qui replace price=price*1.0001 if product==`n'
	predictshr
    rename prob prob_`n'
    drop V
}

replace size = size/1000

gen soda = product<100

keep dm csindex product product size prob_* tm soda sugary

gen q_0 = prob_base*size
foreach n of numlist 1(1)32 110 120 130 140 {
    gen q_`n' = prob_`n'*size
}

drop if product==199|product==999

collapse (sum) q_* ,by(product tm soda sugary)

egen total_a = sum(q_0),by(tm)

qui gen own      = .
qui gen cross_r = .
qui gen cross_d  = .
qui gen cross_ar = .
qui gen cross_ad = .
qui gen total    = .

foreach n of numlist 1(1)32 110 120 130 140 {

    qui gen own_a       = q_0   if product==`n'
    qui gen own_b       = q_`n' if product==`n'
    qui gen crosst_a_r  = q_0   if soda==1 & sugary==1 & product!=`n'
    qui gen crosst_b_r  = q_`n' if soda==1 & sugary==1 & product!=`n'
    qui gen crosst_a_d  = q_0   if soda==1 & sugary==0 & product!=`n'
    qui gen crosst_b_d  = q_`n' if soda==1 & sugary==0 & product!=`n'
    qui gen crosst_a_ar = q_0   if soda==0 & sugary==1 & product!=`n'
    qui gen crosst_b_ar = q_`n' if soda==0 & sugary==1 & product!=`n'
    qui gen crosst_a_ad = q_0   if soda==0 & sugary==0 & product!=`n'
    qui gen crosst_b_ad = q_`n' if soda==0 & sugary==0 & product!=`n'

    qui egen cross_a_r  = sum(crosst_a_r),by(tm)
    qui egen cross_b_r  = sum(crosst_b_r),by(tm)
    qui egen cross_a_d  = sum(crosst_a_d),by(tm)
    qui egen cross_b_d  = sum(crosst_b_d),by(tm)
    qui egen cross_a_ar = sum(crosst_a_ar),by(tm)
    qui egen cross_b_ar = sum(crosst_b_ar),by(tm)
    qui egen cross_a_ad = sum(crosst_a_ad),by(tm)
    qui egen cross_b_ad = sum(crosst_b_ad),by(tm)
    qui egen total_b   = sum(q_`n'),by(tm)

	qui replace own     = ((own_b-own_a)/own_a)*10000                  if product==`n'
    qui replace cross_r  = ((cross_b_r-cross_a_r)/cross_a_r)*10000     if product==`n'
    qui replace cross_d  = ((cross_b_d-cross_a_d)/cross_a_d)*10000     if product==`n'
    qui replace cross_ar = ((cross_b_ar-cross_a_ar)/cross_a_ar)*10000  if product==`n'
    qui replace cross_ad = ((cross_b_ad-cross_a_ad)/cross_a_ad)*10000  if product==`n'
    qui replace total   = ((total_b-total_a)/total_a)*10000            if product==`n'

    drop own_a-total_b
}
drop q_1-q_140
numlabel product,remove

keep product tm soda sugary own cross_r cross_d cross_ar cross_ad total

collapse (mean) soda sugary own cross_r cross_d cross_ar cross_ad total,by(product)

lab var own      "Own price elasticity"
lab var cross_r  "Cross price elasticity for all sugary soft drinks"
lab var cross_d  "Cross price elasticity for all diet soft drinks"
lab var cross_ar "Cross price elasticity for all sugary alternative drinks"
lab var cross_ad "Cross price elasticity for all diet alternative drinks"
lab var total    "Total elasticity for all juice"

sa "$P/MonteCarloResults/$N/elasticities_tableA.dta",replace

u "$P/MonteCarlo/$N/log_coef.dta",clear

gen soda = product<100

gen price_base=price
predictshr
rename prob prob_base
drop V

qui replace price=price_base
qui replace price=price*1.0001 if soda==1
predictshr
rename prob prob_1
drop V

qui replace price=price_base
qui replace price=price*1.0001 if soda==1&sugary==1
predictshr
rename prob prob_2
drop V

replace size = size/1000

keep dm hhno indvno year csindex product product size prob_* tm sugary soda

gen q_0 = prob_base*size
gen q_1 = prob_1*size
gen q_2 = prob_2*size

drop if product==199|product==999

sa "$P/MonteCarlo/$N/catelas_preidctions.dta",replace

u "$P/MonteCarlo/$N/catelas_preidctions.dta",clear

collapse (sum) q_* ,by(product soda sugary tm)

qui gen own_a   = q_0 if soda==1
qui gen own_b   = q_1 if soda==1
qui egen own_aa = sum(own_a),by(tm)
qui egen own_bb = sum(own_b),by(tm)
qui gen own_S = ((own_bb-own_aa)/own_aa)*10000
qui drop own_a-own_bb

qui gen cross_r_S = .

qui gen cross_d_S = .

qui gen cross_ar   = q_0 if soda==0 & sugary==1
qui gen cross_br   = q_1 if soda==0 & sugary==1
qui egen cross_aar = sum(cross_ar),by(tm)
qui egen cross_bbr = sum(cross_br),by(tm)
qui gen cross_ar_S = ((cross_bbr-cross_aar)/cross_aar)*10000
qui drop cross_ar-cross_bbr

qui gen cross_ad   = q_0 if soda==0 & sugary==0
qui gen cross_bd   = q_1 if soda==0 & sugary==0
qui egen cross_aad = sum(cross_ad),by(tm)
qui egen cross_bbd = sum(cross_bd),by(tm)
qui gen cross_ad_S = ((cross_bbd-cross_aad)/cross_aad)*10000
qui drop cross_ad-cross_bbd

qui egen total_a  = sum(q_0),by(tm)
qui egen total_b  = sum(q_1),by(tm)
qui gen  total_S = ((total_b-total_a)/total_a)*10000
qui drop total_a total_b



qui gen own_a   = q_0 if soda==1&sugary==1
qui gen own_b   = q_2 if soda==1&sugary==1
qui egen own_aa = sum(own_a),by(tm)
qui egen own_bb = sum(own_b),by(tm)
qui gen own_SS = ((own_bb-own_aa)/own_aa)*10000
qui drop own_a-own_bb

qui gen cross_r_SS = .

qui gen cross_a   = q_0 if soda==1&sugary==0
qui gen cross_b   = q_2 if soda==1&sugary==0
qui egen cross_aa = sum(cross_a),by(tm)
qui egen cross_bb = sum(cross_b),by(tm)
qui gen cross_d_SS = ((cross_bb-cross_aa)/cross_aa)*10000
qui drop cross_a-cross_bb

qui gen cross_ar   = q_0 if soda==0 & sugary==1
qui gen cross_br   = q_2 if soda==0 & sugary==1
qui egen cross_aar = sum(cross_ar),by(tm)
qui egen cross_bbr = sum(cross_br),by(tm)
qui gen cross_ar_SS = ((cross_bbr-cross_aar)/cross_aar)*10000
qui drop cross_ar-cross_bbr

qui gen cross_ad   = q_0 if soda==0 & sugary==0
qui gen cross_bd   = q_2 if soda==0 & sugary==0
qui egen cross_aad = sum(cross_ad),by(tm)
qui egen cross_bbd = sum(cross_bd),by(tm)
qui gen cross_ad_SS = ((cross_bbd-cross_aad)/cross_aad)*10000
qui drop cross_ad-cross_bbd

qui egen total_a  = sum(q_0),by(tm)
qui egen total_b  = sum(q_2),by(tm)
qui gen   total_SS = ((total_b-total_a)/total_a)*10000
qui drop total_a total_b

keep product tm own_S cross_r_S cross_d_S cross_ar_S cross_ad_S total_S own_SS cross_r_SS cross_d_SS cross_ar_SS cross_ad_SS total_SS

bysort tm: keep if _n==1
drop product

collapse (mean) own_S-total_SS

lab var own_S      "Own price elasticity (Soft drinks)"
lab var cross_r_S  "Cross price elasticity for all sugary soft drinks (Soft drinks)"
lab var cross_d_S  "Cross price elasticity for all diet soft drinks (Soft drinks)"
lab var cross_ar_S "Cross price elasticity for all sugary alternatives (Soft drinks)"
lab var cross_ad_S "Cross price elasticity for all diet alternatives (Soft drinks)"
lab var total_S    "Total elasticity for all juice (Soft drinks)"

lab var own_SS      "Own price elasticity (Sugary soft drinks)"
lab var cross_r_SS  "Cross price elasticity for all sugary soft drinks (Sugary soft drinks)"
lab var cross_d_SS  "Cross price elasticity for all diet soft drinks (Sugary soft drinks)"
lab var cross_ar_SS "Cross price elasticity for all sugary alternatives (Sugary soft drinks)"
lab var cross_ad_SS "Cross price elasticity for all diet alternatives (Sugary soft drinks)"
lab var total_SS    "Total elasticity for all juice (Sugary soft drinks)"

gen i = 1
reshape long own cross_r cross_d cross_ar cross_ad total, i(i) j(X) string

gen     product = 1000 if X=="_S"
replace product = 2000 if X=="_SS"

drop i X
order product

sa "$P/MonteCarloResults/$N/elasticities_tableB.dta",replace

