import json
import boto3
from faker import Faker
import datetime
s3 = boto3.client('s3')
fake = Faker()
def lambda_handler(event, context):
    # Generate mock music data
    data = [{
        "user_id": fake.uuid4(),
        "song_id": fake.random_int(min=1000, max=9999),
        "artist": fake.name(),
        "duration_ms": fake.random_int(min=90000, max=300000),
        "timestamp": datetime.datetime.utcnow().isoformat()
    } for _ in range(50)]  # Generate 50 records per invocation
    
    # Save to S3
    bucket_name = "music-data-akm"  # This will be replaced by environment variable
    key = f"raw_data/{datetime.datetime.utcnow().strftime('%Y-%m-%d-%H-%M-%S')}.json"
    s3.put_object(
        Bucket=bucket_name,
        Key=key,
        Body=json.dumps(data)
    )
    
    return {
        "statusCode": 200,
        "body": json.dumps(f"Generated {len(data)} records. Saved to {bucket_name}/{key}")
    }
