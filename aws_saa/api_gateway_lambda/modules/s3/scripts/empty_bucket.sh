#!/bin/bash
#
# Description
#   delete all files in s3 bucket (make bucket empty)
#   see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/empty-bucket.html
#
# Usage:
#   bash sync.sh
#
set -euo pipefail

# Change to your own settinigs
BACKET_NAME="my-api-gw-lambda-development-env-bucket"

aws s3 rm "s3://${BACKET_NAME}" --recursive
