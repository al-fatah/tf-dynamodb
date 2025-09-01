# DynamoDB with Terraform (Book Inventory)

This creates a DynamoDB table `<yourname>-bookinventory` with:
- Partition key: ISBN (String)
- Sort key: Genre (String)
- On-demand capacity (PAY_PER_REQUEST)

It also uses an S3 backend with a DynamoDB lock table for Terraform state.
