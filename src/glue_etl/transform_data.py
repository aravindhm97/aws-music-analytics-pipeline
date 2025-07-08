from awsglue.context import GlueContext
from pyspark.context import SparkContext

sc = SparkContext()
glueContext = GlueContext(sc)

# Read raw JSON
raw = glueContext.create_dynamic_frame.from_options(
    "s3", 
    {'paths': ["s3://music-data-YOUR_INITIALS/raw_data/"]},
    format="json"
)

# Transform: ms → minutes
def transform(rec):
    rec["duration_min"] = round(rec["duration_ms"] / 60000, 2)
    return rec

transformed = Map.apply(frame=raw, f=transform)

# Write as Parquet
glueContext.write_dynamic_frame.from_options(
    frame=transformed,
    connection_type="s3",
    connection_options={"path": "s3://music-data-YOUR_INITIALS/processed_data/"},
    format="parquet"
)
