# Django + PostgreSQL Final Exam - Comprehensive Deployment Guide

A production-ready Django application with PostgreSQL database, featuring multiple deployment options including local development, Docker Compose, and Kubernetes (AWS EKS) with full infrastructure automation.

---

## 📋 Table of Contents
- [Technologies Used](#technologies-used)
- [Project Architecture](#project-architecture)
- [Prerequisites](#prerequisites)
- [Running Locally (Without Docker)](#running-locally-without-docker)
- [Running with Docker Compose](#running-with-docker-compose)
- [Running on Kubernetes (K8s)](#running-on-kubernetes-k8s)
- [Infrastructure Setup and Teardown](#infrastructure-setup-and-teardown)
- [Monitoring Setup](#monitoring-setup)
- [Testing and Linting](#testing-and-linting)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

---

## 🛠 Technologies Used

### Application Stack
- **Python 3.11** - Programming language
- **Django 4.2+** - Web framework
- **PostgreSQL 15** - Primary database
- **Redis 7** - Caching layer
- **Gunicorn** - WSGI HTTP Server (production)

### DevOps & Infrastructure
- **Docker** - Containerization
- **Docker Compose** - Local multi-container orchestration
- **Kubernetes (K8s)** - Container orchestration platform
- **AWS EKS** - Managed Kubernetes service
- **AWS RDS** - Managed PostgreSQL database
- **AWS ECR** - Container registry
- **Terraform** - Infrastructure as Code (IaC)
- **Ansible** - Configuration management and deployment automation

### Monitoring & Observability
- **Prometheus** - Metrics collection
- **Grafana** - Metrics visualization and dashboards
- **django-prometheus** - Django metrics exporter

### CI/CD
- **GitHub Actions** - Continuous Integration/Deployment
- **Railway** - Alternative cloud deployment platform

### Code Quality
- **Flake8** - Python linting
- **Bandit** - Security vulnerability scanner

---

## 🏗 Project Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Load Balancer                      │
│            (K8s Service / AWS ELB)                   │
└─────────────────────┬───────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
    ┌────▼─────┐            ┌─────▼────┐
    │  Django  │            │  Django  │
    │   Pod 1  │            │   Pod 2  │
    └────┬─────┘            └─────┬────┘
         │                         │
         └────────────┬────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
    ┌────▼─────┐            ┌─────▼────┐
    │   RDS    │            │  Redis   │
    │PostgreSQL│            │  Cache   │
    └──────────┘            └──────────┘
```

### Project Structure
```
.
├── .github/
│   └── workflows/
│       └── main.yml              # CI/CD pipeline
├── ansible/                       # Deployment automation
│   ├── playbook.yaml             # Main deployment playbook
│   ├── cleanup.yaml              # Resource cleanup playbook
│   ├── monitoring.yaml           # Monitoring setup playbook
│   ├── group_vars/
│   │   └── all.yml              # Ansible variables
│   └── inventory/
│       └── aws_ec2.yml          # Dynamic AWS inventory
├── cars/                         # Django app
│   ├── management/
│   │   └── commands/
│   │       └── load_init_data.py
│   ├── models.py
│   ├── views.py
│   └── urls.py
├── infra/                        # Terraform IaC
│   ├── provider.tf              # AWS provider configuration
│   ├── vpc.tf                   # VPC and networking
│   ├── eks.tf                   # EKS cluster
│   ├── rds.tf                   # RDS PostgreSQL
│   ├── ecr.tf                   # Container registry
│   ├── security-groups.tf       # Security groups
│   ├── variables.tf             # Input variables
│   └── outputs.tf               # Output values
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml           # Namespaces (dev/prod/monitoring)
│   ├── configmap.yaml           # Configuration
│   ├── secrets-dev.yaml         # Dev secrets (base64 encoded)
│   ├── secrets-prod.yaml        # Prod secrets (base64 encoded)
│   ├── deployment-dev.yaml      # Dev deployment
│   ├── deployment-prod.yaml     # Prod deployment
│   └── deployment-monitoring.yaml # Prometheus & Grafana
├── myproject/                    # Django project settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── Dockerfile                    # Container image definition
├── docker-compose.yml           # Local development stack
├── requirements.txt             # Python dependencies
├── manage.py                    # Django management script
└── README.md                    # This file
```

---

## 📦 Prerequisites

### Common Prerequisites (All Deployment Methods)
- **Git** - Version control
- **Python 3.11+** - Application runtime
- **PostgreSQL 15** - Database (local setup only)

### For Docker Compose Deployment
- **Docker** 20.10+ - [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose** 2.0+ - Usually included with Docker Desktop

### For Kubernetes Deployment
- **kubectl** - [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **AWS CLI** 2.0+ - [Install AWS CLI](https://aws.amazon.com/cli/)
- **Terraform** 1.5+ - [Install Terraform](https://www.terraform.io/downloads)
- **Ansible** 2.14+ - [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- **AWS Account** with appropriate permissions (EKS, RDS, VPC, ECR)
- **AWS Credentials** configured (`~/.aws/credentials` or environment variables)

### Optional Tools
- **Docker Hub Account** - For custom image registry
- **Railway Account** - For alternative deployment
- **jq** - JSON processor for CLI operations

---

## 🚀 Running Locally (Without Docker)

### Step 1: Install PostgreSQL
Install PostgreSQL 15 on your system and start the service.

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**macOS (with Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
```

### Step 2: Create Database and User
```bash
sudo -u postgres psql

# In PostgreSQL prompt:
CREATE DATABASE carsdb;
CREATE USER carsadmin WITH ENCRYPTED PASSWORD 'carspass';
GRANT ALL PRIVILEGES ON DATABASE carsdb TO carsadmin;
ALTER DATABASE carsdb OWNER TO carsadmin;
\q
```

### Step 3: Clone Repository
```bash
git clone <repository-url>
cd Django-PostgreSQL_Final-Exam
```

### Step 4: Set Up Python Virtual Environment
```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# Linux/macOS:
source venv/bin/activate
# Windows:
venv\Scripts\activate
```

### Step 5: Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 6: Configure Environment Variables
Create a `.env` file in the project root:
```bash
cat > .env << EOF
DB_NAME=carsdb
DB_USER=carsadmin
DB_PASSWORD=carspass
DB_HOST=localhost
DB_PORT=5432
PORT=5000
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
EOF
```

### Step 7: Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py makemigrations cars
python manage.py migrate cars
```

### Step 8: Load Initial Data (Optional)
```bash
python manage.py load_init_data
```

### Step 9: Create Superuser
```bash
python manage.py createsuperuser
# Follow prompts to create admin user
```

### Step 10: Run Development Server
```bash
python manage.py runserver 0.0.0.0:5000
```

Access the application at: **http://localhost:5000**

### Step 11: Run Tests
```bash
python manage.py test
```

---

## 🐳 Running with Docker Compose

Docker Compose provides the easiest way to run the complete application stack locally.

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd Django-PostgreSQL_Final-Exam
```

### Step 2: Create Environment File
Create a `.env` file:
```bash
cat > .env << EOF
DB_NAME=carsdb
DB_USER=carsadmin
DB_PASSWORD=carspass
DB_HOST=db
DB_PORT=5432
PORT=5000
EOF
```

### Step 3: Build and Start Services
```bash
# Build images and start all services
docker compose up --build

# Or run in detached mode (background)
docker compose up --build -d
```

This will start:
- **PostgreSQL** database on port 5432
- **Django** application on port 5000

### Step 4: Run Migrations (First Time Only)
```bash
# In a new terminal window
docker compose exec app python manage.py migrate
docker compose exec app python manage.py makemigrations cars
docker compose exec app python manage.py migrate cars
```

### Step 5: Load Initial Data (Optional)
```bash
docker compose exec app python manage.py load_init_data
```

### Step 6: Create Superuser
```bash
docker compose exec app python manage.py createsuperuser
```

### Step 7: Access Application
- **Application URL**: http://localhost:5000
- **Admin Panel**: http://localhost:5000/admin
- **Car Details**: http://localhost:5000/cars/1

### Useful Docker Compose Commands

```bash
# View logs
docker compose logs -f

# View logs for specific service
docker compose logs -f app

# Stop services
docker compose stop

# Stop and remove containers
docker compose down

# Stop and remove containers + volumes (deletes database data)
docker compose down -v

# Rebuild specific service
docker compose build app

# Run Django management commands
docker compose exec app python manage.py <command>

# Access Django shell
docker compose exec app python manage.py shell

# Access database shell
docker compose exec db psql -U carsadmin -d carsdb

# Run tests
docker compose exec app python manage.py test
```

---

## ☸️ Running on Kubernetes (K8s)

Deploy the application to AWS EKS with full production infrastructure.

### Architecture Overview
- **EKS Cluster** - Managed Kubernetes cluster (1.29)
- **RDS PostgreSQL** - Managed database
- **ECR** - Container registry
- **Load Balancer** - External access via AWS ELB
- **Redis** - In-cluster caching
- **Prometheus & Grafana** - Monitoring stack

### Prerequisites Check
```bash
# Verify installations
aws --version        # AWS CLI
terraform --version  # Terraform
ansible --version    # Ansible
kubectl version      # kubectl
docker --version     # Docker
```

### Step 1: Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (us-east-1)
# - Default output format (json)

# Verify credentials
aws sts get-caller-identity
```

### Step 2: Clone Repository
```bash
git clone <repository-url>
cd Django-PostgreSQL_Final-Exam
```

### Step 3: Review and Update Infrastructure Variables

Edit `infra/terraform.tfvars`:
```hcl
aws_region           = "us-east-1"
project_name         = "django-app"
environment          = "prod"
vpc_cidr            = "10.0.0.0/16"
db_name             = "finalexamdb"
db_username         = "postgres"
eks_cluster_name    = "django-eks-cluster"
eks_node_instance_type = "t3.small"
eks_node_count      = 2
```

### Step 4: Initialize and Apply Terraform

```bash
cd infra

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply infrastructure (will create EKS, RDS, VPC, etc.)
terraform apply
# Type 'yes' to confirm

# Save outputs for later use
terraform output > terraform_output.txt
```

**Expected Resources Created:**
- VPC with public/private subnets
- EKS cluster with 2 worker nodes
- RDS PostgreSQL instance
- ECR repository
- Security groups
- IAM roles and policies

**⏱ Provisioning Time:** ~15-20 minutes

### Step 5: Configure kubectl for EKS

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name django-eks-cluster

# Verify cluster connection
kubectl cluster-info
kubectl get nodes
```

### Step 6: Build and Push Docker Image to ECR

```bash
# Navigate back to project root
cd ..

# Get ECR repository URL from Terraform output
ECR_URL=$(cd infra && terraform output -raw ecr_repository_url)

# Get ECR login token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_URL

# Build image
docker build -t django-app:latest . --no-cache

# Tag image (replace <ecr-url> with your ECR URL from terraform output)
docker tag django-app:latest $ECR_URL:latest

# Push to ECR
docker push $ECR_URL:latest
```

### Step 7: Update Kubernetes Secrets

**For Development Environment:**
Edit `k8s/secrets-dev.yaml` and update base64-encoded values:
```bash
echo -n "your-db-password" | base64
```

**For Production Environment:**
Edit `k8s/secrets-prod.yaml` similarly.

### Step 8: Update Ansible Variables

Edit `ansible/group_vars/all.yml`:
```yaml
aws_region: us-east-1
project_name: django-app
k8s_namespace: django-app-prod

# Get RDS endpoint from terraform output
db_host: "YOUR_RDS_ENDPOINT_FROM_TERRAFORM"
db_name: finalexamdb
db_user: postgres
db_password: "YOUR_DB_PASSWORD"
db_port: 5432

redis_host: redis-service
redis_port: 6379

# ECR URL from terraform output
ecr_repository: "YOUR_ECR_URL"
```

### Step 9: Deploy with Ansible

```bash
cd ansible

# Install Ansible requirements
pip install boto3 botocore
ansible-galaxy collection install -r requirements.yml

# Deploy to production
ansible-playbook playbook.yaml -e "deploy_env=prod db_password=YOUR_DB_PASSWORD"

# Or deploy to development
ansible-playbook playbook.yaml -e "deploy_env=dev db_password=YOUR_DB_PASSWORD"
```

**What this playbook does:**
1. Configures kubectl for EKS
2. Creates namespaces (dev/prod/monitoring)
3. Applies ConfigMaps
4. Creates secrets with DB credentials
5. Deploys Redis
6. Deploys Django application (2 replicas)
7. Runs database migrations
8. Loads initial data
9. Exposes service via LoadBalancer
10. Displays application URL

### Step 10: Verify Deployment

```bash
# Check all resources in production namespace
kubectl get all -n django-app-prod

# Check pod status
kubectl get pods -n django-app-prod

# Check pod logs
kubectl logs -f deployment/django-app -n django-app-prod

# Check services
kubectl get svc -n django-app-prod

# Get LoadBalancer URL
kubectl get svc django-app-service -n django-app-prod \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### Step 11: Access Application

```bash
# Get the LoadBalancer URL
LB_URL=$(kubectl get svc django-app-service -n django-app-prod \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Application URL: http://$LB_URL"
```

**Note:** LoadBalancer DNS propagation may take 2-3 minutes.

### Switching Between Environments

To switch from production to development:
```bash
# Deploy to dev
ansible-playbook playbook.yaml -e "deploy_env=dev db_password=YOUR_DB_PASSWORD"

# Switch kubectl context to dev namespace
kubectl config set-context --current --namespace=django-app-dev

# Or use the switch namespace playbook
ansible-playbook switch-namespace.yaml -e "target_env=dev"
```

### Scaling the Application

```bash
# Scale Django pods to 5 replicas
kubectl scale deployment/django-app --replicas=5 -n django-app-prod

# Verify scaling
kubectl get pods -n django-app-prod

# Auto-scaling (HPA)
kubectl autoscale deployment django-app \
  --cpu-percent=70 --min=2 --max=10 -n django-app-prod
```

---

## 🔧 Infrastructure Setup and Teardown

### Infrastructure Setup (Detailed)

#### 1. Terraform Backend Configuration (Optional but Recommended)

Create S3 bucket for state management:
```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket my-terraform-states-django-app-us-east-1 \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-states-django-app-us-east-1 \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

#### 2. Infrastructure Provisioning

```bash
cd infra

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan infrastructure changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Or apply directly (interactive)
terraform apply
```

#### 3. Extract Terraform Outputs

```bash
# View all outputs
terraform output

# Get specific outputs
terraform output eks_cluster_name
terraform output rds_address
terraform output ecr_repository_url

# Export outputs to file
terraform output -json > terraform_output.txt
```

#### 4. Verify Infrastructure

```bash
# Verify EKS cluster
aws eks describe-cluster --name django-eks-cluster --region us-east-1

# Verify RDS instance
aws rds describe-db-instances --region us-east-1

# Verify ECR repository
aws ecr describe-repositories --region us-east-1

# Verify VPC
aws ec2 describe-vpcs --region us-east-1
```

### Infrastructure Teardown

**⚠️ WARNING: This will permanently delete all infrastructure and data!**

#### Option 1: Full Teardown (Recommended Order)

```bash
# Step 1: Delete Kubernetes resources first
cd ansible
ansible-playbook cleanup.yaml -e "deploy_env=prod"
ansible-playbook cleanup.yaml -e "deploy_env=dev"

# Alternatively, manual cleanup:
kubectl delete namespace django-app-prod
kubectl delete namespace django-app-dev
kubectl delete namespace monitoring

# Step 2: Wait for LoadBalancers to be deleted (important!)
# Check AWS console or CLI until ELBs are gone
aws elb describe-load-balancers --region us-east-1
aws elbv2 describe-load-balancers --region us-east-1

# Step 3: Destroy Terraform infrastructure
cd ../infra
terraform destroy
# Type 'yes' to confirm

# Step 4: Clean up local Terraform files
rm -rf .terraform
rm terraform.tfstate*
rm tfplan
```

#### Option 2: Selective Teardown

Delete specific environments only:
```bash
# Delete only development environment
kubectl delete namespace django-app-dev

# Delete only monitoring
kubectl delete namespace monitoring

# Keep infrastructure but remove application
kubectl delete deployment django-app -n django-app-prod
kubectl delete service django-app-service -n django-app-prod
```

#### Option 3: Using Cleanup Playbook

```bash
cd ansible

# Interactive cleanup (prompts for confirmation)
ansible-playbook cleanup.yaml -e "deploy_env=prod"

# The playbook will:
# 1. Show current resources
# 2. Ask for confirmation
# 3. Delete the specified namespace
# 4. Verify deletion
```

### Troubleshooting Teardown Issues

**Issue: Terraform destroy hangs or fails**
```bash
# Manually delete LoadBalancers
kubectl delete svc --all -n django-app-prod
kubectl delete svc --all -n django-app-dev

# Wait 5 minutes for AWS to clean up

# Force delete persistent resources
aws ec2 describe-network-interfaces --region us-east-1 \
  --filters "Name=vpc-id,Values=YOUR_VPC_ID"

# Then retry terraform destroy
terraform destroy -auto-approve
```

**Issue: Namespace stuck in "Terminating" state**
```bash
# Force delete namespace
kubectl delete namespace django-app-prod --grace-period=0 --force

# If still stuck, remove finalizers
kubectl get namespace django-app-prod -o json \
  | jq '.spec.finalizers = []' \
  | kubectl replace --raw "/api/v1/namespaces/django-app-prod/finalize" -f -
```

---

## 📊 Monitoring Setup

Deploy Prometheus and Grafana for comprehensive monitoring.

### Deploy Monitoring Stack

```bash
cd ansible

# Deploy monitoring to EKS
ansible-playbook monitoring.yaml

# This deploys:
# - Prometheus (metrics collection)
# - Grafana (visualization)
# - Exposes via LoadBalancer
```

### Access Monitoring Services

```bash
# Get Prometheus URL
PROMETHEUS_URL=$(kubectl get svc prometheus-service -n monitoring \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Prometheus: http://$PROMETHEUS_URL:9090"

# Get Grafana URL and credentials
GRAFANA_URL=$(kubectl get svc grafana-service -n monitoring \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
GRAFANA_PASSWORD=$(kubectl get secret grafana-credentials -n monitoring \
  -o jsonpath='{.data.admin-password}' | base64 --decode)

echo "Grafana URL: http://$GRAFANA_URL:3000"
echo "Grafana Username: admin"
echo "Grafana Password: $GRAFANA_PASSWORD"
```

### Configure Grafana Dashboard

1. **Login to Grafana**
   - URL: `http://<GRAFANA_URL>:3000`
   - Username: `admin`
   - Password: (from command above)

2. **Add Prometheus Data Source**
   - Navigate to Configuration → Data Sources
   - Click "Add data source"
   - Select "Prometheus"
   - URL: `http://prometheus-service:9090`
   - Click "Save & Test"

3. **Import Django Dashboard**
   - Navigate to Create → Import
   - Dashboard ID: `9528` (Django Prometheus)
   - Select Prometheus data source
   - Click "Import"

4. **Key Metrics to Monitor**
   - Request rate and latency
   - Database query performance
   - Error rates (4xx, 5xx)
   - Pod CPU and memory usage
   - Redis cache hit ratio

### Monitoring Commands

```bash
# Check monitoring namespace
kubectl get all -n monitoring

# View Prometheus logs
kubectl logs -f deployment/prometheus -n monitoring

# View Grafana logs
kubectl logs -f deployment/grafana -n monitoring

# Port forward Prometheus (local access)
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring

# Port forward Grafana (local access)
kubectl port-forward svc/grafana-service 3000:3000 -n monitoring
```

---

## 🧪 Testing and Linting

### Running Tests

**Local/Virtual Environment:**
```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test cars

# Run with verbosity
python manage.py test --verbosity=2

# Run specific test class
python manage.py test cars.tests.CarModelTests

# Keep test database for inspection
python manage.py test --keepdb
```

**Docker Compose:**
```bash
docker compose exec app python manage.py test
docker compose exec app python manage.py test cars --verbosity=2
```

**Kubernetes:**
```bash
# Get a pod name
POD=$(kubectl get pod -n django-app-prod -l app=django-app \
  -o jsonpath='{.items[0].metadata.name}')

# Run tests
kubectl exec -n django-app-prod $POD -- python manage.py test
```

### Linting and Code Quality

**Install Tools:**
```bash
pip install flake8 bandit black isort
```

**Run Flake8 (Style Checker):**
```bash
# Check all Python files
flake8 .

# Check specific files
flake8 cars/ myproject/

# With configuration file
flake8 --config=.flake8
```

**Run Bandit (Security Scanner):**
```bash
# Scan all files
bandit -r .

# Exclude specific paths
bandit -r . -x ./venv,./env

# Generate JSON report
bandit -r . -f json -o bandit-report.json
```

**Format Code with Black:**
```bash
# Check formatting
black --check .

# Auto-format files
black .

# Format specific files
black cars/ myproject/
```

**Sort Imports with isort:**
```bash
# Check import sorting
isort --check-only .

# Auto-sort imports
isort .
```

### Coverage Analysis

```bash
# Install coverage
pip install coverage

# Run tests with coverage
coverage run --source='.' manage.py test

# Generate report
coverage report

# Generate HTML report
coverage html
# Open htmlcov/index.html in browser
```

---

## 🔄 CI/CD Pipeline

The project includes a comprehensive GitHub Actions workflow.

### Pipeline Overview

**Workflow File:** `.github/workflows/main.yml`

**Stages:**
1. **Build & Install** - Set up Python, install dependencies
2. **Lint** - Run flake8 for code quality
3. **Security Scan** - Run bandit for vulnerabilities
4. **Test** - Run tests with PostgreSQL service
5. **Build Docker Image** - Build and push to Docker Hub/ECR
6. **Deploy** - Deploy to Railway (on `main` branch)

### Required GitHub Secrets

Navigate to: **Settings → Secrets and variables → Actions**

**Required Secrets:**
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token
- `RAILWAY_TOKEN` - Railway deployment token
- `RAILWAY_SERVICE_NAME` - Railway service name
- `AWS_ACCESS_KEY_ID` - AWS access key (optional)
- `AWS_SECRET_ACCESS_KEY` - AWS secret key (optional)

### Triggering the Pipeline

```bash
# Push to any branch triggers CI
git push origin feature-branch

# Push to main triggers CI + deployment
git push origin main

# Manual trigger via GitHub UI
# Go to Actions → Select workflow → Run workflow
```

### Viewing Pipeline Results

```bash
# Using GitHub CLI
gh run list
gh run view <run-id>
gh run watch

# View logs
gh run view <run-id> --log
```

---

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Issue: "Connection refused" to PostgreSQL

**Local Setup:**
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql
sudo systemctl start postgresql

# Verify connection
psql -U carsadmin -d carsdb -h localhost

# Check pg_hba.conf permissions
sudo nano /etc/postgresql/15/main/pg_hba.conf
# Ensure line: host all all 127.0.0.1/32 md5
```

**Docker Compose:**
```bash
# Check database container
docker compose ps
docker compose logs db

# Restart database
docker compose restart db

# Connect to database container
docker compose exec db psql -U carsadmin -d carsdb
```

#### Issue: Migrations not applied

```bash
# Check migration status
python manage.py showmigrations

# Fake initial migration if needed
python manage.py migrate --fake-initial

# Roll back migration
python manage.py migrate cars zero

# Re-apply migrations
python manage.py migrate
```

#### Issue: EKS pods failing to start

```bash
# Check pod status
kubectl get pods -n django-app-prod

# Describe pod for errors
kubectl describe pod <pod-name> -n django-app-prod

# Check logs
kubectl logs <pod-name> -n django-app-prod

# Common fixes:
# 1. Verify secrets are created
kubectl get secrets -n django-app-prod

# 2. Check image pull
kubectl get events -n django-app-prod | grep Failed

# 3. Verify RDS connectivity
kubectl exec -it <pod-name> -n django-app-prod -- \
  python -c "import psycopg2; print('OK')"
```

#### Issue: LoadBalancer stuck in "Pending"

```bash
# Check service
kubectl describe svc django-app-service -n django-app-prod

# Check events
kubectl get events -n django-app-prod

# Verify security groups allow traffic
aws ec2 describe-security-groups --region us-east-1

# Delete and recreate service
kubectl delete svc django-app-service -n django-app-prod
kubectl apply -f k8s/deployment-prod.yaml
```

#### Issue: Terraform state locked

```bash
# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>

# Check DynamoDB lock table
aws dynamodb scan --table-name terraform-locks --region us-east-1
```

#### Issue: Docker build fails

```bash
# Clear Docker cache
docker system prune -a

# Build with no cache
docker build --no-cache -t django-app:latest .

# Check Dockerfile syntax
docker build --dry-run -t django-app:latest .
```

#### Issue: Redis connection timeout

```bash
# Kubernetes - check Redis pod
kubectl get pods -n django-app-prod -l app=redis

# Test Redis connectivity
kubectl exec -it <django-pod> -n django-app-prod -- \
  python -c "import redis; r=redis.Redis(host='redis-service', port=6379); print(r.ping())"

# Docker Compose - check Redis
docker compose exec app python -c "import redis; r=redis.Redis(host='db', port=6379); print(r.ping())"
```

### Useful Diagnostic Commands

```bash
# Check all resources in a namespace
kubectl get all -n django-app-prod

# Get detailed pod information
kubectl describe pod <pod-name> -n django-app-prod

# Access pod shell
kubectl exec -it <pod-name> -n django-app-prod -- /bin/bash

# Check resource usage
kubectl top nodes
kubectl top pods -n django-app-prod

# View recent events
kubectl get events --sort-by='.lastTimestamp' -n django-app-prod

# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup django-app-service

# Check configmaps and secrets
kubectl get configmap -n django-app-prod -o yaml
kubectl get secret db-credentials -n django-app-prod -o yaml
```

---

## 📚 Additional Resources

### Documentation Links
- [Django Documentation](https://docs.djangoproject.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)

### Project URLs
- **Live Application:** https://django-postgresqlmid-exam-production.up.railway.app
- **Sample Endpoints:**
  - View Car: `/cars/1`, `/cars/2`, `/cars/3`
  - Admin Panel: `/admin`
  - Metrics: `/metrics` (Prometheus format)

### Quick Reference Commands

**Docker Compose:**
```bash
docker compose up -d              # Start services
docker compose down               # Stop services
docker compose logs -f            # View logs
docker compose exec app <cmd>    # Run command
```

**Kubernetes:**
```bash
kubectl apply -f <file>          # Apply manifest
kubectl get <resource>           # List resources
kubectl describe <resource>      # Detailed info
kubectl logs -f <pod>            # Stream logs
kubectl exec -it <pod> -- bash   # Access container
```

**Terraform:**
```bash
terraform init                   # Initialize
terraform plan                   # Preview changes
terraform apply                  # Apply changes
terraform destroy                # Destroy infrastructure
terraform output                 # Show outputs
```

**Ansible:**
```bash
ansible-playbook playbook.yaml   # Run playbook
ansible-playbook -e "var=value"  # Pass variables
ansible-playbook --check         # Dry run
```

---

## 📞 Support and Contributing

For issues, questions, or contributions, please refer to the project repository.

---

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

---

**Last Updated:** December 2024