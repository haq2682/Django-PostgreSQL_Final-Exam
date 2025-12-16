# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet. public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS instance address (hostname only)"
  value       = aws_db_instance.main. address
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster. main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority" {
  description = "Certificate authority data for EKS"
  value       = aws_eks_cluster. main.certificate_authority[0]. data
  sensitive   = true
}

# ECR Outputs
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.django_app. repository_url
}

# Useful Commands
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "docker_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.django_app. repository_url}"
}

output "docker_push_command" {
  description = "Command to push image to ECR"
  value       = "docker tag django-app:latest ${aws_ecr_repository.django_app.repository_url}:latest && docker push ${aws_ecr_repository.django_app.repository_url}: latest"
}