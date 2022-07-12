## [DynamoDB](https://aws.amazon.com/jp/dynamodb/?gclid=CjwKCAjwt7SWBhAnEiwAx8ZLatqM7XogqY_3xOMCOsrwtqoncDmPblCgV-YlGHXZDalDsBe77fDj7hoC0IoQAvD_BwE&trk=25b69acf-1b7a-4158-9bbe-df641171b317&sc_channel=ps&sc_campaign=acquisition&sc_medium=ACQ-P|PS-GO|Brand|Desktop|SU|Database|DynamoDB|JP|JP|Text&ef_id=CjwKCAjwt7SWBhAnEiwAx8ZLatqM7XogqY_3xOMCOsrwtqoncDmPblCgV-YlGHXZDalDsBe77fDj7hoC0IoQAvD_BwE:G:s&s_kwcid=AL!4422!3!591672863024!e!!g!!dynamodb)

### Tables

#### employee_list

| key        | type            |
| ---------- | --------------- |
| id         | S: partitionKey |
| first_name | S: attribute    |
| last_name  | S: attribute    |
| office     | S: attribute    |

### Usage

```terraform
module "lambda" {
  source               = "./modules/lambda"
  prefix               = var.prefix
  table-name           = module.dynamodb.employee_list_table.name
  lambda_role-arn      = module.iam.lambda_role-arn
  api_gw-execution-arn = module.api_gateway.api-execution-arn
}
```

#### variables

| variable | description     |
| -------- | --------------- |
| prefix   | production name |
| env      | environment     |

#### outputs

| variable                   | description            |
| -------------------------- | ---------------------- |
| api-execution-arn          | The arn of API Gateway |
| aws_api_gateway_invoke_url | The url of api gateway |
