import boto3
from datetime import datetime, timedelta

s3 = boto3.resource('s3')
bucket = s3.Bucket('music-data-akm')

def lambda_handler(event, context):
    # Delete files older than 2 days
    for obj in bucket.objects.filter(Prefix='raw_data/'):
        if obj.last_modified < datetime.now(obj.last_modified.tzinfo) - timedelta(days=2):
            obj.delete()
    
    return {"deleted_count": "Files cleaned successfully"}