#!/bin/bash
#
# Description
#   update all files in a folder
#   see: https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-services-s3-commands.html
#
# Usage:
#   bash scripts/sync.sh
#
set -euo pipefail

# Change to your own settinigs
BACKET_NAME="my-cloud-front-lambda-edge-development-env-bucket"
SYNC_TARGET_FOLDER="./src"
RIGION="ap-northeast-1"

# Check the current folder
if [ ! -d "./src" ]; then
    echo "You are in the wrong directory."
    echo ""
    echo "Please change directory to s3."
    exit 1
fi

aws s3 sync "${SYNC_TARGET_FOLDER}" "s3://${BACKET_NAME}"/ \
    --include "*" --acl public-read \
    --cache-control "max-age=3600"

echo ""
echo "New resources:"
for file in $(ls ${SYNC_TARGET_FOLDER});
do
    echo "  https://${BACKET_NAME}.s3.${RIGION}.amazonaws.com/${file}"
done
echo ""
