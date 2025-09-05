# DynamoDB with Terraform – alfatah-bookinventory

This project provisions an **AWS DynamoDB** table and supporting infrastructure using **Terraform**.  
It also demonstrates how to attach an **IAM role** to an **EC2 instance** so the instance can read from the table without storing credentials locally.

---

## 🚀 Resources Created
- **DynamoDB Table**
  - Name: `alfatah-bookinventory`
  - Keys:
    - `ISBN` (Partition key, String)
    - `Genre` (Sort key, String)
  - Billing mode: `PAY_PER_REQUEST`
  - Preloaded with sample book data (`aws_dynamodb_table_item`)

- **IAM**
  - Policy: `alfatah-dynamodb-read` (read-only access to the table)
  - Role: `alfatah-dynamodb-read-role` (assumable by EC2)
  - Instance Profile: `alfatah-dynamodb-read-profile` (attached to EC2)

- **EC2 Instance**
  - Amazon Linux 2 (`t2.micro`)
  - Security group allows SSH only from your IP
  - Launched in a minimal custom VPC (public subnet + IGW)
  - Uses the IAM Instance Profile for DynamoDB read access

---