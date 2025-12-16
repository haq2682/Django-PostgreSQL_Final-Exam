variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "django-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# RDS Configuration
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "djangodb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# EKS Configuration
variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "django-eks-cluster"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.small"
}

variable "eks_node_count" {
  description = "Number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
}
