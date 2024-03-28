
import pandas as pd
import numpy as np
from statsmodels.discrete.conditional_models import ConditionalLogit
import statsmodels as sm
import matplotlib.pyplot as plt

data_dyn = "s3://ipsos-dvd/dyn/data/"
figs_dir = "s3://ipsos-dvd/dyn/results/figs/"


if __name__ == "__main__":
    fn = "s3://ipsos-dvd/dyn/data/dwomes_dense_csv/part-00000-07088bba-c486-4d2d-87d3-349deeee12d9-c000.csv"
    cols = list(pd.read_csv(fn,  on_bad_lines='skip', header=0, sep="\t", nrows=1))
    workers= pd.read_csv(fn, usecols =[i for i in cols if i != "open_hours"], 
                         on_bad_lines='skip', header=0, sep="\t")

    
    workers['strata'] = workers['caid'] + workers['week'].astype(str)

    # create chain fixed effects
    workers['chainweek'] = workers['chain'] + workers['week'].astype(str)
    workers = pd.concat([workers, pd.get_dummies(workers['chain'], prefix="chain_", 
                                                 dtype="int")], axis=1)
    
    workers = pd.concat([workers, pd.get_dummies(workers['week'], prefix="week_", 
                                                dtype="int")], axis=1)
    
    workers = pd.concat([workers, pd.get_dummies(workers['chainweek'], prefix="chainweek_", 
                                            dtype="int")], axis=1)

    for prefix in [1, 2]: 
        allcols = workers.columns
        if prefix == 1:
            exog_names = [x for x in allcols if "salary" in x or "chain_" in x]
        else:
            exog_names = [x for x in allcols if "salary" in x or "chainweek_" in x]
        exog_names = exog_names + ['distance', 'distance_sq']
        endog_names = 'pr_work'

        mdl = ConditionalLogit( # **kwargs are for LikelihoodModel Class
            endog = np.array(workers[endog_names]),
            exog = np.array(workers[exog_names]),
            groups = np.array(workers['strata'])
        )

        res = mdl.fit(maxiter=10000, method="lbfgs", disp=True, full_output=True, skip_hessian=True, 
                      warn_convergence=True)

        resdf = pd.DataFrame([(res.params[i], exog_names[i]) for i in range(len(exog_names))], columns = ['beta', 'name'])

        resdf.to_csv(data_dyn + "clogit_out_" + str(prefix) + ".csv", index=False)
        
        resdf = pd.read_csv(data_dyn + "clogit_out_" + str(prefix) + ".csv")
            
        fig, ax = plt.subplots(1,1)
        resdf[resdf.name.str.contains("salary")].hist(bins=50, ax=ax)
        #plt.xlim(-0.02, 0.02)