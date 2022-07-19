# CloudFront-Lambda@Edge

AWS-SAA でよくみる構成を作ってみようシリーズ [#16](https://github.com/kokoichi206/cloud-prac/issues/16)

## Architecture

![](./docs/architecture.svg)

## Usage

```sh
# Production deploy
$ terraform apply -var="env=production"
```

### [variables](./variables.tf)

| variable | description                                                                |
| -------- | -------------------------------------------------------------------------- |
| prefix   | The prifix of the service                                                  |
| env      | The environment where the service works (production, staging, development) |

### [outputs](./outputs.tf)

| output  | description      |
| ------- | ---------------- |
| sqs_arn | sqs arn to check |

## Modules

-   [Lambda](./modules/lambda/)
-   [S3](./modules/s3/)
-   [sqs](./modules/sqs/)
