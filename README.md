# DynamoDB with Terraform: alfatah-bookinventory

This repo provisions:
- DynamoDB table: `alfatah-bookinventory`
  - Partition key: `ISBN` (String)
  - Sort key: `Genre` (String)
- Terraform remote backend: S3 + DynamoDB lock table

## Prereqs
- Terraform >= 1.5
- AWS CLI configured (`aws configure`) with permissions to create DynamoDB tables and access S3.

## 0) Create/choose S3 bucket and lock table (one-time)
You can create these once per account/region (or reuse existing):

```bash
# Replace BUCKET_NAME and REGION
export BUCKET_NAME=tfstate-alfatah-123456
export REGION=ap-southeast-1
export LOCK_TABLE=terraform-locks

aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  --region "$REGION"

aws dynamodb create-table \
  --table-name "$LOCK_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"
