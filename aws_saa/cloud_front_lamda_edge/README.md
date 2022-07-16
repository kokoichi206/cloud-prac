# CloudFront-Lambda@Edge

AWS-SAA でよくみる構成を作ってみようシリーズ [#5](https://github.com/kokoichi206/cloud-prac/issues/5)

## Architecture

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

| output              | description                                           |
| ------------------- | ----------------------------------------------------- |
| s3_domain           | The url of s3 bucket                                  |
| cloud_front_domain  | The url of cloud-front and you should access this URL |
| dynamodb_table_name | The main db table name                                |

### Modules

-   [DynamoDB](./modules/dynamodb/)
-   [Lambda](./modules/lambda/)
-   [S3](./modules/s3/)
-   [Cloud Front](./modules/cloud_front/)
