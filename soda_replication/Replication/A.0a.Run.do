
clear
cap log close
set more off

***Set file paths
do "./DuboisGriffithOConnell2020/Programs/0.b.paths.do"


do "$pg/A.1a.Kantar.do"
do "$pg/A.1b.NDNS.do"
do "$pg/A.1c.NHANES.do"
do "$pg/A.1d.Price.do"


do "$pg/A.2.Output.do"
