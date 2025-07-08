import boto3
from datetime import datetime, timedelta
def lambda_handler(event, context):
    s3 = boto3.resource('s3')
    bucket_name = "music-data-akm"
    bucket = s3.Bucket(bucket_name)
    deleted_count = 0
    # Delete raw data files older than 2 days
    for obj in bucket.objects.filter(Prefix='raw_data/'):
        if obj.last_modified < datetime.now(obj.last_modified.tzinfo) - timedelta(days=2):
            obj.delete()
            deleted_count += 1
    return {
        "statusCode": 200,
        "body": f"Deleted {deleted_count} objects from {bucket_name}/raw_data/"
    }
