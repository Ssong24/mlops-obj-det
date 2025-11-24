# variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "s3_bucket_name" {}
variable "ecr_repository_name" {}
variable "ec2_instance_type" {
  default = "t3.micro" # cost saving default
}
variable "ec2_key_name" {}
variable "ec2_security_group_ids" {
  type = list(string)
}
variable "ec2_subnet_id" {}
variable "domain_name" {}
variable "certificate_arn" {}
