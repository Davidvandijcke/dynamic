
#-------
#### Relation between wages and prices #### 
#------- 


# set variable names
dict <- c("wage_log"="Log(Wage)", 
          "price_log"="Log(Price)",
          "cz"="Market",
          "distance_shoppers_log" = "Log(Km. to Shoppers)",
          "distance_shoppers" = "Km. to Shoppers",
          "distance_shoppers_sq" = "Km. to Shoppers$^2$",
          "distance_workers_log" = "Log(Km. to Workers)",
          "distance_workers" = "Km. to Workers",
          "distance_workers_sq" = "Km. to Workers$^2$",
          "month" = "Month",
          "chain" = "Chain"
)
fixest::setFixest_dict(dict)



# load data
data <- fread(file.path(data_dir, "price_wage_panel_monthly.csv.gz"))

i <- 1
for (fe in c("", "| cz", "| cz^month", "| chain")) {
  mdl <- fixest::feols(as.formula(paste0("wage_log ~ price_log", fe)), data = data)
  assign(paste0("m", i), mdl)
  i <- i + 1
}


#### To LaTeX and beyond! 
a <- etable(mget(paste0("m", seq(1,i-1))), fitstat = ~ n + my + ar2,
            depvar = TRUE, 
            tex = TRUE, digits='r4')
cat(a, file = file.path(tabs, 'wages_prices_reg.tex'))


#-------
#### Relation between wages, prices, and distance #### 
#-------
# load data
data <- fread(file.path(data_dir, "price_wage_panel_distances.csv.gz"))


i <- 1
for (yvar in c("wage_log", "price_log")) {
  for (fe in c("", "| cz", "| chain")) {
    if (yvar == "wage_log") { xvar <- "distance_workers + distance_workers_sq" } else { xvar <- "distance_shoppers + distance_shoppers_sq" } 
    mdl <- fixest::feols(as.formula(paste0(yvar, "~", xvar, fe)), data = data)
    assign(paste0("m", i), mdl)
    i <- i + 1
  }
}



#### To LaTeX and beyond! 

# create latex table: part a
a <- etable(mget(paste0("m", seq(1,i-1))), fitstat = ~ n + my + ar2,
            depvar = TRUE,
            tex = TRUE, digits='r4')
cat(a, file = file.path(tabs, 'wages_prices_location_reg.tex'))



#-------
#### Relation between wages and prices #### 
#-------




# load data
data <- fread(file.path(data_dir, "price_wage_panel_distances.csv.gz"))

i <- 1
for (fe in c("", "| cz", "| chain")) {
  mdl <- fixest::feols(as.formula(paste0("distance_shoppers ~ distance_workers + distance_workers_sq", fe)), data = data)
  assign(paste0("m", i), mdl)
  i <- i + 1
}


#### To LaTeX and beyond! 

# create latex table: part a
a <- etable(mget(paste0("m", seq(1,i-1))), fitstat = ~ n + my + ar2,
            depvar = TRUE, 
            tex = TRUE, digits='r4')
cat(a, file = file.path(tabs, 'distances_reg.tex'))



