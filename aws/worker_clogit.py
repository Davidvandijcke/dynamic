"""Stay location and duration finding using the D-Star algorithm


aws emr add-steps --cluster-id <Your EMR cluster id> --steps Type=spark,Name=TestJob,Args=[--deploy-mode,cluster,--master,yarn,--conf,spark.yarn.submit.waitAppCompletion=true,s3a://your-source-bucket/code/pythonjob.py,s3a://your-source-bucket/data/data.csv,s3a://your-destination-bucket/test-output/],ActionOnFailure=CONTINUE
"""
import pandas as pd
import numpy as np
from statsmodels.discrete.conditional_models import ConditionalLogit

data_dyn = "s3://ipsos-dvd/dyn/data/"
figs_dir = "s3://ipsos-dvd/dyn/results/figs/"


if __name__ == "__main__":
    workers = pd.read_csv("s3://ipsos-dvd/dyn/data/dwomes_dense_csv/part-00000-58a1eeb4-33ed-4cf2-b937-2a7e2bbf027b-c000.csv",
                          on_bad_lines='skip', nrows=100000)
    workers['strata'] = workers['caid'] + workers['week'].astype(str)

    # create chain fixed effects
    workers['chainweek'] = workers['chain'] + workers['week'].astype(str)
    workers = pd.concat([workers, pd.get_dummies(workers['chainweek'], prefix="chain_", dtype="int")], axis=1)

    allcols = workers.columns
    exog_names = [x for x in allcols if "salary" in x] # or "chain_" in x]
    exog_names = exog_names + ['distance', 'distance_sq']
    endog_names = 'pr_work'

    mdl = ConditionalLogit( # **kwargs are for LikelihoodModel Class
        endog = np.array(workers[endog_names]),
        exog = np.array(workers[exog_names]),
        groups = np.array(workers['strata'])
    )

    res = mdl.fit(maxiter=100)

    resdf = pd.DataFrame([(res.params[i], exog_names[i]) for i in range(len(exog_names))], columns = ['beta', 'name'])

    resdf.to_csv(data_dyn + "clogit_out.csv", index=False)
