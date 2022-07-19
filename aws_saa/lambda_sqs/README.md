# CloudFront-Lambda@Edge

AWS-SAA でよくみる構成を作ってみようシリーズ [#16](https://github.com/kokoichi206/cloud-prac/issues/16)

## Usage

```sh
# Production deploy
$ terraform apply -var="env=production"
```

### [variables](./variables.tf)

| variable | description                                         | defalut       |
| -------- | --------------------------------------------------- | ------------- |
| prefix   | production name                                     | api_gw_lambda |
| env      | environment<br />(production, staging, development) | development   |

### [outputs](./outputs.tf)

| output | description |
| ------ | ----------- |

## Modules

-   [DynamoDB](./modules/dynamodb/)
-   [Lambda](./modules/lambda/)
-   [S3](./modules/s3/)
-   [Cloud Front](./modules/cloud_front/)
