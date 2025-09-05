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

# ---- Dummy data ----
locals {
  books = [
    {
      ISBN   = "9780131103627"
      Genre  = "Computer Science"
      Title  = "The C Programming Language"
      Author = "Kernighan & Ritchie"
      Price  = 199.90
      Stock  = 12
    },
    {
      ISBN   = "9781491950296"
      Genre  = "DevOps"
      Title  = "Site Reliability Engineering"
      Author = "Beyer, Jones, Petoff, Murphy"
      Price  = 249.00
      Stock  = 7
    },
    {
      ISBN   = "9780596007126"
      Genre  = "Programming"
      Title  = "Head First Design Patterns"
      Author = "Freeman & Robson"
      Price  = 180.00
      Stock  = 25
    },
    {
      ISBN   = "9780262046305"
      Genre  = "AI"
      Title  = "Deep Learning"
      Author = "Goodfellow, Bengio, Courville"
      Price  = 320.00
      Stock  = 9
    },
    {
      ISBN   = "9780007350803"
      Genre  = "Fantasy"
      Title  = "The Hobbit"
      Author = "J.R.R. Tolkien"
      Price  = 59.90
      Stock  = 30
    },
  ]
}

# Create one item per book using for_each
resource "aws_dynamodb_table_item" "books" {
  for_each   = { for b in local.books : "${b.ISBN}#${b.Genre}" => b }
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = "ISBN"
  range_key  = "Genre"

  # DynamoDB JSON (typed) must be used; numbers are strings.
  item = jsonencode({
    ISBN   = { S = each.value.ISBN }
    Genre  = { S = each.value.Genre }
    Title  = { S = each.value.Title }
    Author = { S = each.value.Author }
    Price  = { N = format("%.2f", each.value.Price) }
    Stock  = { N = tostring(each.value.Stock) }
  })
}

