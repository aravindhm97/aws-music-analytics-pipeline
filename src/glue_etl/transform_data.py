import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
# Read raw data from S3
raw_data = glueContext.create_dynamic_frame.from_options(
    "s3",
    {'paths': ["s3://music-data-akm/raw_data/"]},
    format="json"
)
# Convert to DataFrame to use Spark SQL
df = raw_data.toDF()
# Calculate duration in minutes
from pyspark.sql.functions import col, round
df = df.withColumn("duration_min", round(col("duration_ms") / 60000, 2))
# Write processed data to S3 in Parquet format
output_path = "s3://music-data-akm/processed_data/"
df.write.mode("append").parquet(output_path)
job.commit()
