## API Gateway + Lambda

![](./docs//architecture.svg)

### Usage

```sh
# Production deploy
$ terraform apply -var="env=production"
```

#### [variables](./variables.tf)

| variable | description                                         | defalut       |
| -------- | --------------------------------------------------- | ------------- |
| prefix   | production name                                     | api_gw_lambda |
| env      | environment<br />(production, staging, development) | development   |

#### [outputs](./outputs.tf)

| variable           | description            |
| ------------------ | ---------------------- |
| api_gateway_domain | The url of api gateway |
| s3_domain          | The url of s3 bucket   |

### Modules

-   [DynamoDB](./modules/dynamodb/)
-   [Lambda](./modules/lambda/)
    -   [IAM Role for Lambda](./modules/iam_role/)
-   [S3](./modules/s3/)
-   [API Gateway](./modules/api-gateway/)
