import subprocess
import sys
import time
import logging

# ET_2020_3 is 2020-01-01/2020-09-01


NAME = "filter"
CLUSTER_ID = "j-2241ZOH48D18E"


emr_cli_step_cmd_parquet_template_grab = (
        "aws emr add-steps --cluster-id {CLUSTER_ID} --steps"
        " Type=spark,Name={name},Args=[--deploy-mode,cluster,--master,yarn,"
        "--conf,spark.yarn.submit.waitAppCompletion=true,"
        "s3://ipsos-dvd/scripts/worker_clogit.py],ActionOnFailure=CONTINUE --profile ipsos --region us-east-1"
    )
logging.info("Template: %s", emr_cli_step_cmd_parquet_template_grab)


if __name__ == "__main__":

    # grab the data and save it 

    curr_step = emr_cli_step_cmd_parquet_template_grab.format(
            CLUSTER_ID=CLUSTER_ID,
            name=NAME
        )
    print(curr_step)
    logging.info("Curr step: %s\n\n", curr_step)
    resp = subprocess.run(curr_step, shell=True, capture_output=True)

#aws emr add-steps --cluster-id <Your EMR cluster id> --steps Type=spark,Name=TestJob,Args=[--deploy-mode,cluster,--master,yarn,--conf,spark.yarn.submit.waitAppCompletion=true,s3a://your-source-bucket/code/pythonjob.py,s3a://your-source-bucket/data/data.csv,s3a://your-destination-bucket/test-output/],ActionOnFailure=CONTINUE
