## initialize

``` sh
brew install asdf
asdf plugin add terraform
asdf list all terraform
asdf install terraform 1.5.4
```

``` sh
terraform init

# doesn't work...
# terraform import aws_s3_bucket.main kokoichi-awesome-bucket

# it worked!!
$ terraform import module.s3.aws_s3_bucket.main kokoichi-awesome-bucket

module.s3.data.aws_iam_policy_document.s3_bucket_policy: Reading...
module.s3.data.aws_iam_policy_document.s3_bucket_policy: Read complete after 0s [id=1512064624]
module.s3.aws_s3_bucket.main: Importing from ID "kokoichi-awesome-bucket"...
module.s3.aws_s3_bucket.main: Import prepared!
  Prepared aws_s3_bucket for import
module.s3.aws_s3_bucket.main: Refreshing state... [id=kokoichi-awesome-bucket]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

## apply

``` sh
terraform plan

terraform apply
```

## Links

- [terraform: s3 bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket.html)
- [terraform: s3_bucket_lifecycle_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)
- [ライフサイクルルールの適応](https://repost.aws/ja/knowledge-center/s3-lifecycle-rule-delay)
  - 1日1回, UTC 00:00 に実行されるらしい
- [Setting lifecycle configuration on a bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-set-lifecycle-configuration-intro.html)
