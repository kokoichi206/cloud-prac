import os
import json
import boto3
from typing import Any, Dict


dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud_front_lambda_edge_development_employee_list')


def handler(
    event: Dict[str, Any],
    context  # : aws_lambda_powertools.utilities.typing.LambdaContext,
) -> Dict[str, Any]:
    """条件によって表示するページを変える。

    * 判断条件はクエリパラメータに有効な名前が含まれるかどうか。
    * dynamodbに該当の名前が存在するかのチェックを行う。
    * dynamodbはリージョンに依存したサービスであることに注意。
    * see: https://awslabs.github.io/aws-lambda-powertools-python/latest/utilities/typing/#lambdacontext

    Args:
        event (Dict[str, Any]):
            Json message passed to lambda.
        context (LambdaContext):
            Information about the invocation, function, and execution environment.

    Returns:
        Dict[str, Any]:
            Return value as a http response.
    """

    # CloudWatchLogs用に出力しておく。
    print(event)

    # クエリパラメータに有効な名前（ID）があった場合、ホームへリダイレクトする。
    params = event.get('Records')[0].get(
        'cf').get('request').get('querystring')
    # CloudWatchLogs用に出力しておく。
    print(params)

    if params:
        # 'name=a0001&id=21' -> {'name': 'a0001', 'id': '21'}
        params_dict = {k[0]: k[1] for k in list(
            map(lambda x: x.split('='), params.split('&')))}
        id = params_dict.get('name')
        if id:
            response = table.get_item(Key={'id': id})
            # CloudWatchLogs用に出力しておく。
            print(response)
            if "Item" in response:
                return {
                    'status': '302',
                    'statusDescription': 'Found',
                    'headers': {
                        'location': [{
                            'key': 'Location',
                            'value': 'https://github.com/kokoichi206/cloud-prac/issues/5'
                            # 'value': 'https://my-cloud-front-lambda-edge-development-env-bucket.s3.amazonaws.com/home.html'
                        }]
                    }
                }

    # クエリパラメータに有効な名前（ID）がなかった場合、エラーページへリダイレクトする。
    return {
        'status': '302',
        'statusDescription': 'Found',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': 'https://google.com'
            }]
        }
    }
