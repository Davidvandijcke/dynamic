# 
# # load data from S3
# spark_install(version="3.0")
# config<-spark_config()
# config$sparklyr.defaultPackages <- c(
#   "com.amazonaws:aws-java-sdk-pom:1.10.34",
#   "org.apache.hadoop:hadoop-aws:2.7.3")
# #Spark Connection
# sc <- spark_connect(master = "local", version="3.0", config=config)
# 
# # read all parquet files
# bucket <- "ipsos-dvd"
# prefix <- "dyn/data/dwomes_dense/" # Ensure it ends with a slash
# objs <- s3$list_objects_v2(Bucket = bucket, Prefix = prefix)
# files <- s3$contents[objs$Contents]
# parquet_files <- sapply(files, function(f) {
#   if(grepl("\\.parquet$", f$Key)) {
#     sprintf("s3://%s/%s", bucket, f$Key)
#   }
# })
# parquet_files <- parquet_files[!is.na(parquet_files)]
# 
# #Get spark context 
# ctx <- sparklyr::spark_context(sc)
# #Use below to set the java spark context 
# jsc <- invoke_static( sc, "org.apache.spark.api.java.JavaSparkContext", "fromSparkContext", ctx )
# 
# ## load data and filter in spark before passing to data table
# ## load data and filter in spark before passing to data table
# sparkdf <- spark_read_parquet(sc, name = "people_tenure_prepped",
#                               path = "s3a://ipsos-dvd/dyn/data/dwomes_dense/",
#                               memory = FALSE)

s3.fread <- function(s3_path) {
  s3_pattern <- "^s3://(.+?)/(.*)$"
  s3_bucket <- gsub(s3_pattern, "\\1", s3_path)
  s3_object <- gsub(s3_pattern, "\\2", s3_path)
  fread(text = rawToChar(aws.s3::get_object(s3_object, s3_bucket)))
}

data_dir <- "s3://ipsos-dvd/dyn/data/"

workers <- fread(paste0(data_dir, "dwomes_dense_csv/*.csv"))

s3_path <- "s3://ipsos-dvd/dyn/data/dwomes_dense_csv/part-00000-6c0c0575-a929-4b20-a0b0-835cbcea13e9-c000.csv"
workers <- s3.fread(s3_path)


bucket <- 'ipsos-dvd'
file <- 'dyn/data/dwomes_dense_csv/part-00000-6c0c0575-a929-4b20-a0b0-835cbcea13e9-c000.csv'

df <- aws.s3::s3read_using(FUN = read.csv, object = file, bucket = bucket)


