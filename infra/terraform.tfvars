aws_region   = "us-east-1"
project_name = "django-app"
environment  = "production"

# Database Configuration
db_name     = "finalexamdb"
db_username = "postgres"
db_password = "postgres"

# EKS Configuration
eks_cluster_name       = "django-eks-cluster"
eks_node_instance_type = "t3.small"
eks_node_count         = 2

app_port = 5000
