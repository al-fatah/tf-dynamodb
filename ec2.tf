###############################################
# Minimal public VPC + EC2 with IAM profile  #
###############################################

# 1) VPC + Internet Gateway
resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "lab-vpc" }
}

resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab.id
  tags = { Name = "lab-igw" }
}

# 2) One public subnet (auto-assign public IPs)
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "lab_public_az1" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "lab-public-az1" }
}

# 3) Route table for internet access
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }
  tags = { Name = "lab-public-rt" }
}

resource "aws_route_table_association" "lab_public_assoc" {
  subnet_id      = aws_subnet.lab_public_az1.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# 4) Security group (SSH allowed from your IP only)
resource "aws_security_group" "ec2_sg" {
  name        = "alfatah-ec2-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr] # 180.74.225.21/32
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alfatah-ec2-sg" }
}

# 5) Latest Amazon Linux 2 AMI (gp2/gp3)
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2", "amzn2-ami-hvm-*-x86_64-gp3"]
  }
}

# 6) Instance Profile (already created in your iam.tf)
resource "aws_iam_instance_profile" "dynamodb_read_profile" {
  name = "alfatah-dynamodb-read-profile"
  role = aws_iam_role.dynamodb_read_role.name
}

# 7) EC2 instance (uses instance profile for DynamoDB read)
resource "aws_instance" "dynamodb_reader" {
  ami                    = data.aws_ami.amazon_linux2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.lab_public_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.dynamodb_read_profile.name

  # Optional: install AWS CLI on boot
  # user_data = <<-EOF
  #   #!/bin/bash
  #   yum -y update
  #   yum -y install awscli
  #   # Example: test DynamoDB (uncomment after instance is up)
  #   # aws dynamodb scan --table-name alfatah-bookinventory --region ${data.aws_region.current.name} > /root/scan.json
  # EOF

  tags = { Name = "alfatah-dynamodb-reader" }
}

# (Optional) Detect current region if needed by user_data above
data "aws_region" "current" {}

# 8) Helpful outputs
output "ec2_public_ip" {
  value = aws_instance.dynamodb_reader.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.dynamodb_reader.public_dns
}

output "vpc_id" {
  value = aws_vpc.lab.id
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}

