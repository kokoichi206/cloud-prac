import os
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('TABLE_NAME'))

def handler(event, context):
    response = table.scan(Limit=5)
    items = response['Items']
    # employee_info = table.get_item(Key={'EmployeeId': 'a00000110'})['Item']
    # employee_id = employee_info['EmployeeId']
    # employee_firstname = employee_info['FirstName']
    # employee_lastname = employee_info['LastName']
    # employee_office = employee_info['Office']
    return {
        "isBase64Encoded": False,
        'statusCode': 200,
        'body': json.dumps(items),
    }
    # return {
    #     "isBase64Encoded": False,
    #     'statusCode': 200,
    #     'body': json.dumps({
    #         'Id': employee_id,
    #         'Firstname': employee_firstname,
    #         'Lastname': employee_lastname,
    #         'Office': employee_office,
    #     })
    # }
