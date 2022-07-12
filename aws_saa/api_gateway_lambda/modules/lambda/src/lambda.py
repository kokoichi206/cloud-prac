import os
import json
import boto3
from typing import Any, Dict


dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('TABLE_NAME'))


def handler(
    event: Dict[str, Any],
    context  # : aws_lambda_powertools.utilities.typing.LambdaContext,
) -> Dict[str, Any]:
    """dynamodbからメンバーの一覧を取得する。

    * 上限は5人としている。
    * see: https://awslabs.github.io/aws-lambda-powertools-python/latest/utilities/typing/#lambdacontext

    Args:
        event (Dict[str, Any]):
            Json message passed to lambda.
        context (LambdaContext):
            Information about the invocation, function, and execution environment.

    Returns:
        Dict[str, Any]:
            Return value for API Gateway.
    """

    response = table.scan(Limit=5)
    items = response['Items']

    return {
        'isBase64Encoded': False,
        'statusCode': 200,
        'body': json.dumps(items),
    }
