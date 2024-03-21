
#****************************************************************************************************************************************************

# LOAD LIBRARIES

#****************************************************************************************************************************************************

# load packages
packages_not_load <- c()
packages_load <- c("data.table", "fixest")

# lapply(c(packages_load, packages_not_load),  function(x) install.packages(x, dependencies=TRUE)),

{
  sink("/dev/null") # load packages but suppress output
  if (!require("pacman")) install.packages("pacman")
  pacman::p_load(char = packages_load, character.only = TRUE)
  
  
  sink()
  
}
