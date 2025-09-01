# DynamoDB with Terraform: alfatah-bookinventory

This repo provisions:
- DynamoDB table: `alfatah-bookinventory`
  - Partition key: `ISBN` (String)
  - Sort key: `Genre` (String)
- Terraform remote backend: S3 + DynamoDB lock table
