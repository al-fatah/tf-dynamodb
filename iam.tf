# IAM policy: alfatah-dynamodb-read
resource "aws_iam_policy" "dynamodb_read" {
  name        = "alfatah-dynamodb-read"
  description = "Read-only access (list + read) to the alfatah-bookinventory DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          # List operations
          "dynamodb:List*",
          # Read operations
          "dynamodb:Get*",
          "dynamodb:Describe*",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.book_inventory.arn
      }
    ]
  })
}

# IAM Role: alfatah-dynamodb-read-role
resource "aws_iam_role" "dynamodb_read_role" {
  name = "alfatah-dynamodb-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # EC2 can assume this role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the read-only policy to the role
resource "aws_iam_role_policy_attachment" "dynamodb_read_attach" {
  role       = aws_iam_role.dynamodb_read_role.name
  policy_arn = aws_iam_policy.dynamodb_read.arn
}

