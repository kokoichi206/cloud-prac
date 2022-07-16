import boto3


BUCKET_NAME = "my-cloud-front-lambda-edge-development-env-bucket"

s3 = boto3.resource('s3')
bucket = s3.Bucket(BUCKET_NAME)
bucket.object_versions.delete()
