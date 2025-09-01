# DynamoDB table: alfatah-bookinventory
# Keys per activity: ISBN (partition, String), Genre (sort, String)
resource "aws_dynamodb_table" "book_inventory" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # default, no capacity planning needed
  hash_key     = "ISBN"
  range_key    = "Genre"

  attribute {
    name = "ISBN"
    type = "S"
  }

  attribute {
    name = "Genre"
    type = "S"
  }

  tags = {
    Project = "aws-dbaas-dynamodb"
    Owner   = "alfatah"
    Env     = "prod"
  }
}
