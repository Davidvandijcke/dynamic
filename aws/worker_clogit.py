"""Stay location and duration finding using the D-Star algorithm


aws emr add-steps --cluster-id <Your EMR cluster id> --steps Type=spark,Name=TestJob,Args=[--deploy-mode,cluster,--master,yarn,--conf,spark.yarn.submit.waitAppCompletion=true,s3a://your-source-bucket/code/pythonjob.py,s3a://your-source-bucket/data/data.csv,s3a://your-destination-bucket/test-output/],ActionOnFailure=CONTINUE
"""
import pandas as pd
import numpy as np
from statsmodels.discrete.conditional_models import ConditionalLogit

data_dyn = "s3://ipsos-dvd/dyn/data/"
figs_dir = "s3://ipsos-dvd/dyn/results/figs/"


if __name__ == "__main__":
    workers = pd.read_csv(data_dyn + "dwomes_dense.csv")
    workers['strata'] = workers['caid'] + workers['week'].astype(str)

    # create chain fixed effects
    workers['chain_week'] = workers['chain'] + workers['week'].astype(str)
    workers = pd.concat([workers, pd.get_dummies(workers['chain'], prefix="chain_")])

    allcols = workers.columns
    endog_names = [x for x in allcols if "salary" in x or "chain_" in x]
    endog_names = endog_names + ['distance', 'distance_sq', 'total_caids', 'total_caids_sq']
    exog_names = 'pr_work'

    mdl = ConditionalLogit( # **kwargs are for LikelihoodModel Class
        endog = np.array(workers[exog_names]),
        exog = np.array(workers[endog_names]),
        groups = np.array(workers['strata'])
    )

    res = mdl.fit(method="lbfgs", maxiter=5000)

    resdf = pd.DataFrame([(res.params[i], endog_names[i]) for i in range(len(endog_names))], columns = ['beta', 'name'])

    resdf.to_csv(data_dyn + "clogit_out.csv", index=False)
