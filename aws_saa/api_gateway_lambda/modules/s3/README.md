## S3

### SPA

Source code is in [this](./src/) folder.

#### delete s3 contents

make s3 bucket empty (contents only)

```sh
$ bash scripts/empty_bucket.sh
```

#### deploy

```sh
$ bash scripts/sync.sh
```

#### before destroy

make s3 bucket empty (fully)

```sh
$ python scripts/bucket_full_empty.py
```

### Usage

```terraform
module "s3" {
  source = "./modules/s3"
  prefix = var.prefix
  env    = var.env
}
```

#### variables

| variable | description     |
| -------- | --------------- |
| prefix   | production name |
| env      | environment     |

#### outputs

| variable          | description          |
| ----------------- | -------------------- |
| aws_s3_bucket_url | The url of s3 bucket |
