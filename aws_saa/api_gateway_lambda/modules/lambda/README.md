## [Lambda](https://aws.amazon.com/jp/lambda/)

### Functions

Python source code is in [this](./src/) folder.

### Usage

``` terraform
module "lambda" {
  source               = "./modules/lambda"
  prefix               = var.prefix
  table-name           = module.dynamodb.employee_list_table.name
  lambda_role-arn      = module.iam.lambda_role-arn
  api_gw-execution-arn = module.api_gateway.api-execution-arn
}
```

#### variables

| variable             | description                     |
| -------------------- | ------------------------------- |
| prefix               | production name                 |
| table-name           | table name of DynamoDB          |
| lambda_role-arn      | IAM role to handle DynamoDB     |
| api_gw-execution-arn | API Gateway arn lambda works on |

#### outputs

| variable   | description                               |
| ---------- | ----------------------------------------- |
| invoke-arn | The lambda arn for API Gateway to connect |

### TODO

-   Avoid hard-coding for s3 bucket url in [lambda.py](./src/lambda.py)
