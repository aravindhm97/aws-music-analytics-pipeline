import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext

glueContext = GlueContext(SparkContext.getOrCreate())

# Read raw data
raw_data = glueContext.create_dynamic_frame.from_options(
    "s3",
    {'paths': ["s3://music-data-akm/raw_data/"]},
    format="json"
)

# Calculate duration in minutes
def transform(rec):
    rec["duration_min"] = round(rec["duration_ms"] / 60000, 2)
    return rec

transformed = Map.apply(frame=raw_data, f=transform)

# Write processed data
glueContext.write_dynamic_frame.from_options(
    frame=transformed,
    connection_type="s3",
    connection_options={"path": "s3://music-data-akm/processed_data/"},
    format="parquet"
)