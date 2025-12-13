provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# -------------------------
# S3 Bucket for artifacts
# -------------------------
resource "aws_s3_bucket" "mlflow_bucket" {
  bucket = var.s3_bucket_name
}


# Create a new EC2 key pair
resource "aws_key_pair" "mlops_key" {
  key_name   = var.ec2_key_name # e.g. "mlops-keypair"
  public_key = file(pathexpand("~/.ssh/mlops-keypair.pub"))

}


# EC2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


# -----------------------------
# Networking Setup
# -----------------------------

# 1. Create a VPC
resource "aws_vpc" "mlops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mlops-vpc"
  }
}

# 2. Create a public subnet
resource "aws_subnet" "mlops_subnet" {
  vpc_id                  = aws_vpc.mlops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "mlops-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "mlops_igw" {
  vpc_id = aws_vpc.mlops_vpc.id

  tags = {
    Name = "mlops-igw"
  }
}

# 4. Route Table
resource "aws_route_table" "mlops_rt" {
  vpc_id = aws_vpc.mlops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mlops_igw.id
  }

  tags = {
    Name = "mlops-rt"
  }
}

# 5. Associate route table with subnet
resource "aws_route_table_association" "mlops_rta" {
  subnet_id      = aws_subnet.mlops_subnet.id
  route_table_id = aws_route_table.mlops_rt.id
}




resource "aws_instance" "api_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.mlops_key.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.mlops_subnet.id   # 👈 NEW
  associate_public_ip_address = true                          # 👈 NEW
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "mlops-api-server"
  }
}

resource "aws_security_group" "sg" {
  name        = "mlops-sg"
  description = "Allow SSH and HTTP/HTTPS"
  vpc_id = aws_vpc.mlops_vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # "194.100.50.67/32"-> 이거 안됨 , "0.0.0.0/0"

  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "mlops-ec2-role"
  assume_role_policy = jsonencode ({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": { 
          "Service": "ec2.amazonaws.com" 
          },
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EC2 instance profile 
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "mlops-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach S3 read access
resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# Lifecycle rule to expire old artifacts (cost saving)
resource "aws_s3_bucket_lifecycle_configuration" "mlflow_lifecycle" {
  bucket = aws_s3_bucket.mlflow_bucket.id

  rule {
    id     = "expire-old-artifacts"
    status = "Enabled"

    filter {
      prefix = "" # applies to all objects in the bucket
    }

    expiration {
      days = 5
    }
  }
}

# -------------------------
# ECR Repository
# -------------------------
resource "aws_ecr_repository" "yolo_repo" {
  name = "yolo-inference"
}


# Lifecycle policy: keep last 10 images only
resource "aws_ecr_lifecycle_policy" "mlops_policy" {
  repository = aws_ecr_repository.yolo_repo.name

  policy = jsonencode({
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep only last 10 images",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  })
  
}
