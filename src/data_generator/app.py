import boto3, json
from faker import Faker

def lambda_handler(event, context):
    fake = Faker()
    # Generate 50 mock music records
    data = [{ 
        "user_id": fake.uuid4(),
        "song_id": fake.random_int(min=1000, max=9999),
        "artist": fake.name(),
        "duration_ms": fake.random_int(min=90000, max=300000),
        "timestamp": fake.iso8601()
    } for _ in range(50)]
    
    # Save to S3
    s3 = boto3.client('s3')
    s3.put_object(
        Bucket="music-data-YOUR_INITIALS",  # From Terraform
        Key=f"raw_data/{fake.date()}.json",
        Body=json.dumps(data)
    )
