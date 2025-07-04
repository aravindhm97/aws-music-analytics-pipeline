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
    } for _ in range(50)]
    
    # Save to S3
    s3.put_object(
        Bucket="music-data-akm",  # Match your bucket name
        Key=f"raw_data/{datetime.date.today()}.json",
        Body=json.dumps(data)
    )
    
    return {"status": 200, "message": f"Generated {len(data)} records"}