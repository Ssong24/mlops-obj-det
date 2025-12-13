# variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

# Removed: aws_access_key and aws_secret_key (using OIDC instead)

variable "s3_bucket_name" {
  description = "S3 bucket name for MLflow artifacts"
  type        = string
}
variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "yolo-inference" # matches my main.tf
}
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # cost saving default
}
variable "ec2_key_name" {
  description = "EC2 key pair name"
  type = string
}

variable "ec2_public_key" {
  description = "EC2 public key content"
  type        = string
}

variable "ec2_security_group_ids" {
  description = "Security group IDs for EC2 instance"
  type = list(string)
  default = [] # Optional: will use the one created in main.tf
}
variable "ec2_subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
  default     = "" # Optional: will use the one created in main.tf
}
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "" # Make optional if not using custom domain
}
variable "certificate_arn" {
  description = "ACM certificate ARM for HTTPS"
  type        = string
  default     = "" # Make optional if not using HTTPS
}
