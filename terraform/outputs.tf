# outputs.tf
output "ecr_repository_url" {
  value = aws_ecr_repository.yolo_repo.repository_url
  description = "The URI of the ECR repository"
}
