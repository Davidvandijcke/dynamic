
clear
cap log close
set more off

***Set file paths
do "./DuboisGriffithOConnell2020/Programs/0.b.paths.do"
***Set globals
do "$pg/0.c.globals.do"

****Create data for estimation
do "$pg/1.a.createdata.do"

****Estimate demand model
***Run on HPC***
do "$hpg/2.a.estimation.do"
***************

****Descriptive files
do "$pg/3.a.descriptives.do"
do "$pg/3.b.demandlinkages.do"

****Set up files for results
do "$pg/4.a.filesetup.do"

****Estimates
do "$pg/5.a.passthroughdesc.do"
*******
**Run Matlab file estimates.m 
*******
do "$pg/5.b.estimates.do"
do "$pg/5.c.priceeffects.do"

****Counterfactual 
do "$pg/6.a.counterfactual.do"

***Confidence bands
do "$pg/7.a.coefdraws.do"

foreach n of numlist 1(1)$BR {

    global MC "$rs/MonteCarlo/`n'"
    global MCR "$rs/MonteCarloResults/`n'"
    capture confirm file "$MC/nul"
    if _rc>0 {
        mkdir "$MC"
        mkdir "$MCR"
    }
    global N "`n'"

	do "$pg/7.b.prepare_ci.do"
	do "$pg/7.c.priceeffects_ci.do"
	do "$pg/7.d.counterfactual_ci.do"
}

****Robustness

**Jackknife
***Run on HPC***
do "$hpg/8.a.jackknife.do" 
***************
do "$pg/8.b.jackknife.do" 

**At-home
****Estimate demand 
do "$pg/8.c.foodindata.do"
***Run on HPC***
do "$hpg/8.d.estimation.do"
***************
do "$pg/8.e.filesetup.in.do"
do "$pg/8.f.foodin.do" 

**Supply
do "$pg/8.g.passthrough1.do"
********
***Run Matlab file Passthroug/Run.m
********
do "$pg/8.h.passthrough2.do"
do "$pg/8.i.eqcounterfactual.do"

****Output results
do "$pg/9.a.tables.do"
do "$pg/9.b.graphs.do"
********
**Run Matlab file graphs.m 
********


