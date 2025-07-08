import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):
    bucket = boto3.resource('s3').Bucket("music-data-YOUR_INITIALS")
    deleted = 0
    # Delete files >2 days old
    for obj in bucket.objects.filter(Prefix='raw_data/'):
        if obj.last_modified < datetime.now(obj.last_modified.tzinfo) - timedelta(days=2):
            obj.delete()
            deleted += 1
    return {"deleted": deleted}
