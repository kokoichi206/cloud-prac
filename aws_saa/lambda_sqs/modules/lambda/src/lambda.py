import boto3


def handler(event, context):
    s3 = boto3.resource('s3')
    message = event['Records'][0]['body']
    file_name = event['Records'][0]['messageId']
    with open("/tmp/sqs.json", "w") as f:
        f.write(message)
    s3.meta.client.upload_file(
        '/tmp/sqs.json', 'my-lambda-sqs-development-env-bucket', f'{file_name}.json')
