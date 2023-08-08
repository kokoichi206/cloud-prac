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
terraform import module.s3.aws_s3_bucket.main minio-compatibility-test
```

## apply

``` sh
terraform plan

terraform apply
```

## Links

- [s3 bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket.html)
- [s3_bucket_lifecycle_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)
