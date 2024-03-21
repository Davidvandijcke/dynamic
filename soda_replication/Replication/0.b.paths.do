*********************************************
**To run code you must set up the following folder structure
**********************************************

********************
****File paths for desktop 
********************

**Master directory
global dry "./DuboisGriffithOConnell2020"

**Programs 
global pg "$dry/Programs"

**HPC
global nhp "./DuboisGriffithOConnell2020"

**Derived datas
global cd "$dry/Data/CreateData"
global ds "$dry/Data/Descriptives"
global rs "$dry/Data/RunResults"

**Results
global dr "$dry/Results/Descriptives"
global jr "$dry/Results/Jackknife"
global rr "$dry/Results/RunResults"

********************
****File paths for HPC
********************

**Master directories
global hpc "./DuboisGriffithOConnell2020"
global net "./DuboisGriffithOConnell2020"

**HPC paths
global hjk "$hpc/Jacknife"

**Network paths
global hcd "$net/Data/CreateData"
global hds "$net/Data/Descriptives"
global hrs "$net/Data/RunResults"

global hpg "$net/Programs"
