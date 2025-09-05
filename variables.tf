variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "alfatah-bookinventory"
}

variable "my_ip_cidr" {
  default = "0.0.0.0/0"
}

