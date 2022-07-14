import boto3


BUCKET_NAME = "my-api-gw-lambda-development-env-bucket"

s3 = boto3.resource('s3')
bucket = s3.Bucket(BUCKET_NAME)
bucket.object_versions.delete()
