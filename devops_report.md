# DevOps Report - Django PostgreSQL Production Deployment

**Project:** Enterprise Django Application with Multi-Environment Infrastructure  
**Author:** DevOps Team  
**Last Updated:** December 2024

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Architecture & Infrastructure](#3-architecture--infrastructure)
4. [CI/CD Pipeline](#4-cicd-pipeline)
5. [Secret Management Strategy](#5-secret-management-strategy)
6. [Monitoring & Observability Strategy](#6-monitoring--observability-strategy)
7. [Deployment Workflows](#7-deployment-workflows)
8. [Testing Strategy](#8-testing-strategy)
9. [Lessons Learned](#9-lessons-learned)
10. [Best Practices & Recommendations](#10-best-practices--recommendations)

---

## 1. Project Overview

### Project Description
A production-ready Django application with PostgreSQL database, deployed across multiple environments (development, production) using modern DevOps practices. The project demonstrates enterprise-grade infrastructure automation, containerization, orchestration, and monitoring.

### Key Features
- **Multi-environment deployment** (dev, prod, monitoring)
- **Infrastructure as Code** (Terraform)
- **Configuration Management** (Ansible)
- **Container Orchestration** (Kubernetes on AWS EKS)
- **CI/CD Automation** (GitHub Actions)
- **Comprehensive Monitoring** (Prometheus + Grafana)
- **High Availability** (Multiple replicas, auto-scaling capabilities)

### Project Goals
1. Automate infrastructure provisioning and teardown
2. Implement zero-downtime deployments
3. Ensure security through secret management and vulnerability scanning
4. Enable real-time monitoring and alerting
5. Support rapid development through containerization
6. Maintain infrastructure consistency through IaC

---

## 2. Technology Stack

### Application Layer
| Technology | Version | Purpose |
|------------|---------|---------|
| Python | 3.11 | Application runtime |
| Django | 4.2+ | Web framework |
| PostgreSQL | 15 | Primary database |
| Redis | 7 | Caching & session storage |
| psycopg2 | Latest | PostgreSQL adapter |
| django-redis | Latest | Redis integration |

### Infrastructure & DevOps
| Technology | Version | Purpose |
|------------|---------|---------|
| Docker | 20.10+ | Containerization |
| Docker Compose | 2.0+ | Local orchestration |
| Kubernetes | 1.29 | Container orchestration |
| AWS EKS | 1.29 | Managed Kubernetes |
| AWS RDS | PostgreSQL 15 | Managed database |
| AWS ECR | - | Container registry |
| Terraform | 1.5+ | Infrastructure as Code |
| Ansible | 2.14+ | Configuration management |

### Monitoring & Observability
| Technology | Version | Purpose |
|------------|---------|---------|
| Prometheus | Latest | Metrics collection |
| Grafana | Latest | Visualization & dashboards |
| django-prometheus | Latest | Django metrics exporter |
| prometheus-client | Latest | Python metrics library |

### CI/CD & Quality
| Technology | Version | Purpose |
|------------|---------|---------|
| GitHub Actions | - | CI/CD pipeline |
| Railway | - | Alternative deployment |
| Flake8 | Latest | Code linting |
| Bandit | Latest | Security scanning |

---

## 3. Architecture & Infrastructure

### 3.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │   AWS Load Balancer     │
            │      (ELB/ALB)          │
            └────────────┬────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
    ┌────▼─────┐                   ┌────▼─────┐
    │   EKS    │                   │   EKS    │
    │ Worker 1 │                   │ Worker 2 │
    └────┬─────┘                   └────┬─────┘
         │                               │
         │  ┌───────────────────────────┤
         │  │                           │
    ┌────▼──▼──────┐            ┌──────▼─────┐
    │ Django Pod 1  │            │ Django Pod 2│
    │ + Redis Cache │            │ + Redis Cache│
    └────┬──────────┘            └──────┬──────┘
         │                               │
         └───────────────┬───────────────┘
                         │
         ┌───────────────┴────────────────┐
         │                                │
    ┌────▼─────┐                  ┌──────▼──────┐
    │   RDS    │                  │   Redis     │
    │PostgreSQL│                  │  Cluster    │
    │ (Primary)│                  │ (In-cluster)│
    └──────────┘                  └─────────────┘
         │
    ┌────▼─────┐
    │   RDS    │
    │PostgreSQL│
    │ (Standby)│
    └──────────┘
```

### 3.2 Network Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        AWS VPC (10.0.0.0/16)                      │
│                                                                   │
│  ┌─────────────────────────┐  ┌──────────────────────────┐      │
│  │  Public Subnet (AZ-1a)  │  │  Public Subnet (AZ-1b)   │      │
│  │     10.0.1.0/24         │  │     10.0.2.0/24          │      │
│  │                         │  │                          │      │
│  │  - NAT Gateway         │  │  - NAT Gateway          │      │
│  │  - Load Balancer       │  │  - Load Balancer        │      │
│  └─────────────────────────┘  └──────────────────────────┘      │
│                                                                   │
│  ┌─────────────────────────┐  ┌──────────────────────────┐      │
│  │ Private Subnet (AZ-1a)  │  │ Private Subnet (AZ-1b)   │      │
│  │     10.0.11.0/24        │  │     10.0.12.0/24         │      │
│  │                         │  │                          │      │
│  │  - EKS Worker Nodes    │  │  - EKS Worker Nodes     │      │
│  │  - Django Pods         │  │  - Django Pods          │      │
│  │  - Redis Pods          │  │  - Redis Pods           │      │
│  └─────────────────────────┘  └──────────────────────────┘      │
│                                                                   │
│  ┌─────────────────────────┐  ┌──────────────────────────┐      │
│  │  Database Subnet (AZ-1a)│  │ Database Subnet (AZ-1b)  │      │
│  │     10.0.21.0/24        │  │     10.0.22.0/24         │      │
│  │                         │  │                          │      │
│  │  - RDS Primary         │  │  - RDS Standby          │      │
│  └─────────────────────────┘  │                          │      │
│                                └──────────────────────────┘      │
└──────────────────────────────────────────────────────────────────┘
```

### 3.3 Kubernetes Cluster Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                    EKS Cluster (django-eks-cluster)            │
│                                                                │
│  ┌──────────────────────┐  ┌──────────────────────┐          │
│  │  Namespace: dev      │  │  Namespace: prod     │          │
│  │                      │  │                      │          │
│  │  ┌────────────────┐ │  │  ┌────────────────┐ │          │
│  │  │ Django App     │ │  │  │ Django App     │ │          │
│  │  │ (2 replicas)   │ │  │  │ (2 replicas)   │ │          │
│  │  └────────────────┘ │  │  └────────────────┘ │          │
│  │                      │  │                      │          │
│  │  ┌────────────────┐ │  │  ┌────────────────┐ │          │
│  │  │ Redis          │ │  │  │ Redis          │ │          │
│  │  │ (1 replica)    │ │  │  │ (1 replica)    │ │          │
│  │  └────────────────┘ │  │  └────────────────┘ │          │
│  │                      │  │                      │          │
│  │  ConfigMaps          │  │  ConfigMaps          │          │
│  │  Secrets             │  │  Secrets             │          │
│  │  Services            │  │  Services            │          │
│  └──────────────────────┘  └──────────────────────┘          │
│                                                                │
│  ┌──────────────────────────────────────────────────┐        │
│  │         Namespace: monitoring                     │        │
│  │                                                   │        │
│  │  ┌──────────────┐      ┌──────────────┐         │        │
│  │  │  Prometheus  │ ───▶ │   Grafana    │         │        │
│  │  │              │      │              │         │        │
│  │  │  - Scrapes   │      │  - Dashboard │         │        │
│  │  │  - Stores    │      │  - Alerts    │         │        │
│  │  │  - Alerts    │      │  - Queries   │         │        │
│  │  └──────────────┘      └──────────────┘         │        │
│  └──────────────────────────────────────────────────┘        │
└───────────────────────────────────────────────────────────────┘
```

### 3.4 Infrastructure Components

#### AWS Resources (Terraform Managed)
1. **VPC & Networking**
   - VPC with CIDR 10.0.0.0/16
   - 2 public subnets across 2 AZs
   - 2 private subnets for worker nodes
   - 2 database subnets for RDS
   - Internet Gateway for public access
   - NAT Gateways for private subnet internet access
   - Route tables for traffic management

2. **EKS Cluster**
   - Kubernetes version 1.29
   - Managed control plane
   - 2 worker nodes (t3.small)
   - Auto-scaling group
   - IAM roles and policies
   - Security groups

3. **RDS PostgreSQL**
   - PostgreSQL 15 engine
   - Multi-AZ deployment
   - Automated backups
   - Encryption at rest
   - Private subnet placement
   - Security group restrictions

4. **ECR Repository**
   - Private container registry
   - Image scanning enabled
   - Lifecycle policies
   - Cross-region replication ready

5. **Security Groups**
   - EKS cluster security group
   - Worker node security group
   - RDS database security group
   - Application load balancer security group

#### Kubernetes Resources
1. **Namespaces**
   - `django-app-dev` - Development environment
   - `django-app-prod` - Production environment
   - `monitoring` - Monitoring stack

2. **Deployments**
   - Django application (2 replicas)
   - Redis cache (1 replica)
   - Prometheus server
   - Grafana dashboard

3. **Services**
   - Django LoadBalancer service (external)
   - Redis ClusterIP service (internal)
   - Prometheus ClusterIP service (internal)
   - Grafana LoadBalancer service (external)

4. **Configuration**
   - ConfigMaps for environment-specific settings
   - Secrets for sensitive data (DB credentials, API keys)

---

## 4. CI/CD Pipeline

### 4.1 Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                         │
│                   (Source Code + Infrastructure)                 │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ git push (main/PR)
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub Actions Runner                       │
│                                                                  │
│  ┌────────────────┐         ┌────────────────┐                 │
│  │ Stage 1:       │         │ Stage 2:       │                 │
│  │ Validate       │────────▶│ Build & Test   │                 │
│  │ - File checks  │         │ - Python setup │                 │
│  │ - Config       │         │ - Dependencies │                 │
│  └────────────────┘         │ - Unit tests   │                 │
│                              └────────┬───────┘                 │
│                                       │                          │
│  ┌────────────────┐         ┌────────▼───────┐                 │
│  │ Stage 3:       │◀────────│ Stage 4:       │                 │
│  │ Security       │         │ Lint & Format  │                 │
│  │ - Bandit scan  │         │ - Flake8       │                 │
│  │ - Dependency   │         │ - Code style   │                 │
│  └────────┬───────┘         └────────────────┘                 │
│           │                                                      │
│           ▼                                                      │
│  ┌────────────────┐                                             │
│  │ Stage 5:       │                                             │
│  │ Build Image    │                                             │
│  │ - Docker build │                                             │
│  │ - Tag          │                                             │
│  │ - Push to ECR  │                                             │
│  └────────┬───────┘                                             │
└───────────┼─────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AWS ECR                                   │
│                  (Container Registry)                            │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ [main branch only]
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Deployment Stage                              │
│                                                                  │
│  ┌────────────────┐         ┌────────────────┐                 │
│  │ Terraform      │         │ Ansible        │                 │
│  │ Validation     │────────▶│ Deployment     │                 │
│  │                │         │ - kubectl      │                 │
│  └────────────────┘         │ - Migrations   │                 │
│                              │ - Rollout      │                 │
│                              └────────┬───────┘                 │
└─────────────────────────────────────┼─────────────────────────┘
                                      │
                                      ▼
                        ┌──────────────────────────┐
                        │    EKS Cluster (AWS)     │
                        │  Running Application     │
                        └──────────────────────────┘
```

### 4.2 Pipeline Stages

#### Stage 1: File Validation
**Purpose:** Ensure all required infrastructure and configuration files exist  
**Tools:** Bash scripts  
**Actions:**
- Validate Ansible playbooks exist
- Verify Kubernetes manifests
- Check Terraform configuration files
- Confirm directory structure

**Exit Criteria:**
- All required files present
- No missing dependencies

#### Stage 2: Build & Test
**Purpose:** Verify application code quality and functionality  
**Tools:** Python, pip, Django test framework  
**Actions:**
- Set up Python 3.11 environment
- Install dependencies from requirements.txt
- Run database migrations
- Execute unit tests with PostgreSQL service
- Generate test coverage report

**Exit Criteria:**
- All tests pass
- Code coverage meets threshold
- No critical errors

#### Stage 3: Security Scanning
**Purpose:** Identify security vulnerabilities  
**Tools:** Bandit, dependency checkers  
**Actions:**
- Scan Python code for security issues
- Check for known vulnerabilities in dependencies
- Validate secret management practices
- Review file permissions

**Exit Criteria:**
- No high-severity vulnerabilities
- Security best practices followed

#### Stage 4: Code Quality
**Purpose:** Enforce code standards  
**Tools:** Flake8, Black (optional)  
**Actions:**
- Run linting checks
- Validate PEP 8 compliance
- Check code complexity
- Review documentation strings

**Exit Criteria:**
- Linting passes
- Code style consistent

#### Stage 5: Container Build
**Purpose:** Create deployable container image  
**Tools:** Docker, AWS CLI  
**Actions:**
- Build multi-stage Docker image
- Tag with commit SHA and 'latest'
- Authenticate with AWS ECR
- Push image to registry
- Scan image for vulnerabilities (optional)

**Exit Criteria:**
- Image builds successfully
- Image pushed to ECR
- Image size optimized

#### Stage 6: Deploy (Main Branch Only)
**Purpose:** Deploy to target environment  
**Tools:** Terraform, Ansible, kubectl  
**Actions:**
- Validate Terraform state
- Update Kubernetes manifests
- Deploy via Ansible playbook
- Run database migrations
- Wait for pods to be ready
- Verify deployment health

**Exit Criteria:**
- All pods running
- Health checks passing
- Application accessible

### 4.3 Pipeline Configuration

```yaml
# Simplified GitHub Actions workflow structure
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  EKS_CLUSTER_NAME: django-eks-cluster
  ECR_REPOSITORY: django-app

jobs:
  validate-files:
    runs-on: ubuntu-latest
    steps:
      - Validate infrastructure files
      - Check required configurations

  build-and-test:
    needs: validate-files
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
    steps:
      - Setup Python
      - Install dependencies
      - Run migrations
      - Execute tests

  security-scan:
    needs: build-and-test
    runs-on: ubuntu-latest
    steps:
      - Run Bandit security scanner
      - Check dependencies

  lint:
    needs: build-and-test
    runs-on: ubuntu-latest
    steps:
      - Run Flake8 linting

  build-image:
    needs: [security-scan, lint]
    runs-on: ubuntu-latest
    steps:
      - Build Docker image
      - Push to ECR

  deploy:
    needs: build-image
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - Configure kubectl
      - Run Ansible deployment
      - Verify deployment
```

### 4.4 Deployment Strategies

#### Rolling Update
- Default Kubernetes strategy
- Gradual replacement of pods
- Zero downtime deployment
- Automatic rollback on failure

#### Blue-Green Deployment (Optional)
- Separate dev and prod namespaces
- Switch traffic between environments
- Quick rollback capability

#### Canary Deployment (Future)
- Gradual traffic shifting
- Monitor metrics before full rollout
- Risk mitigation

---

## 5. Secret Management Strategy

### 5.1 Secret Management Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Secret Management Layers                      │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Layer 1: Development (Local)                 │  │
│  │                                                           │  │
│  │  .env file (gitignored)                                   │  │
│  │  ├── DB_NAME=carsdb                                       │  │
│  │  ├── DB_USER=carsadmin                                    │  │
│  │  ├── DB_PASSWORD=localpass                                │  │
│  │  └── DB_HOST=localhost                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Layer 2: CI/CD (GitHub Actions)              │  │
│  │                                                           │  │
│  │  GitHub Secrets (encrypted at rest)                       │  │
│  │  ├── AWS_ACCESS_KEY_ID                                    │  │
│  │  ├── AWS_SECRET_ACCESS_KEY                                │  │
│  │  ├── DOCKERHUB_TOKEN                                      │  │
│  │  ├── DB_PASSWORD                                          │  │
│  │  └── RAILWAY_TOKEN                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          Layer 3: Kubernetes (Production)                 │  │
│  │                                                           │  │
│  │  Kubernetes Secrets (base64 encoded, etcd encrypted)      │  │
│  │  ├── db-credentials                                       │  │
│  │  │   ├── DB_NAME                                          │  │
│  │  │   ├── DB_USER                                          │  │
│  │  │   ├── DB_PASSWORD                                      │  │
│  │  │   ├── DB_HOST (RDS endpoint)                           │  │
│  │  │   ├── REDIS_HOST                                       │  │
│  │  │   └── REDIS_PORT                                       │  │
│  │  └── grafana-credentials                                  │  │
│  │      ├── admin-user                                       │  │
│  │      └── admin-password                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │       Layer 4: Infrastructure (Terraform/Ansible)         │  │
│  │                                                           │  │
│  │  Environment Variables / Ansible Vault                    │  │
│  │  ├── TF_VAR_db_password (runtime)                         │  │
│  │  ├── AWS credentials via AWS CLI config                   │  │
│  │  └── Ansible variables (group_vars)                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Secret Types & Storage

#### GitHub Secrets
**Purpose:** CI/CD pipeline authentication and sensitive data  
**Encryption:** AES-256-GCM  
**Access:** Repository collaborators with write access

| Secret Name | Purpose | Used In |
|-------------|---------|---------|
| `AWS_ACCESS_KEY_ID` | AWS authentication | Image push, deployment |
| `AWS_SECRET_ACCESS_KEY` | AWS authentication | Image push, deployment |
| `DOCKERHUB_USERNAME` | Docker Hub login | Image push (optional) |
| `DOCKERHUB_TOKEN` | Docker Hub authentication | Image push (optional) |
| `RAILWAY_TOKEN` | Railway deployment | Alternative deployment |
| `RAILWAY_SERVICE_NAME` | Railway service identifier | Alternative deployment |
| `DB_PASSWORD` | Test database password | CI testing |

#### Kubernetes Secrets
**Purpose:** Runtime application secrets  
**Encoding:** Base64  
**Encryption:** etcd encryption at rest (AWS managed)

**Secret: db-credentials**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: django-app-prod
type: Opaque
data:
  DB_NAME: <base64-encoded>
  DB_USER: <base64-encoded>
  DB_PASSWORD: <base64-encoded>
  DB_HOST: <base64-encoded>
  DB_PORT: <base64-encoded>
  REDIS_HOST: <base64-encoded>
  REDIS_PORT: <base64-encoded>
```

**Secret: grafana-credentials**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana-credentials
  namespace: monitoring
type: Opaque
data:
  admin-user: <base64-encoded>
  admin-password: <base64-encoded>
```

#### Terraform Variables
**Purpose:** Infrastructure provisioning  
**Storage:** Environment variables, terraform.tfvars (gitignored)

**Sensitive Variables:**
- `db_password` - RDS master password
- `db_username` - RDS master username (marked sensitive)

**Usage:**
```bash
# Pass via environment variable
export TF_VAR_db_password="secure-password"
terraform apply

# Or via command line (not recommended for production)
terraform apply -var="db_password=secure-password"
```

#### Ansible Variables
**Purpose:** Deployment configuration  
**Storage:** group_vars/all.yml, command-line arguments

**Best Practice:**
```bash
# Pass sensitive variables at runtime
ansible-playbook playbook.yaml \
  -e "deploy_env=prod" \
  -e "db_password=${DB_PASSWORD}"
```

### 5.3 Secret Management Best Practices

#### ✅ DO
1. **Never commit secrets to Git**
   - Use .gitignore for .env files
   - Review commits before pushing
   - Use pre-commit hooks

2. **Rotate secrets regularly**
   - Database passwords every 90 days
   - API tokens every 180 days
   - TLS certificates before expiry

3. **Use least privilege principle**
   - Grant minimal required permissions
   - Separate dev and prod credentials
   - Use IAM roles instead of keys when possible

4. **Encrypt secrets at rest**
   - Enable etcd encryption in Kubernetes
   - Use AWS Secrets Manager for critical secrets (optional)
   - Encrypt Ansible vaults

5. **Audit secret access**
   - Log secret usage
   - Monitor for unauthorized access
   - Review access patterns

#### ❌ DON'T
1. **Don't hardcode secrets in code**
2. **Don't share secrets via insecure channels**
3. **Don't use same secrets across environments**
4. **Don't commit secrets even in "private" repos**
5. **Don't log secrets in application output**

### 5.4 Secret Rotation Workflow

```
1. Generate new secret
   ↓
2. Create new Kubernetes secret (new version)
   ↓
3. Update application deployment to use new secret
   ↓
4. Wait for all pods to restart with new secret
   ↓
5. Verify application functionality
   ↓
6. Update database/service with new credentials
   ↓
7. Delete old Kubernetes secret
   ↓
8. Document rotation in change log
```

---

## 6. Monitoring & Observability Strategy

### 6.1 Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer (Django)                    │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Django Application (with django-prometheus)             │  │
│  │                                                           │  │
│  │  Metrics Exported:                                        │  │
│  │  ├── HTTP requests (rate, duration, status codes)        │  │
│  │  ├── Database queries (count, duration)                  │  │
│  │  ├── Cache hits/misses (Redis)                           │  │
│  │  ├── Exception counts                                    │  │
│  │  └── Custom business metrics                             │  │
│  │                                                           │  │
│  │  Endpoint: /metrics (Prometheus format)                  │  │
│  └────────────────────┬─────────────────────────────────────┘  │
└─────────────────────────┼───────────────────────────────────────┘
                          │
                          │ HTTP scrape (every 15s)
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Prometheus Server (monitoring namespace)        │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Prometheus                                               │  │
│  │                                                           │  │
│  │  Functions:                                               │  │
│  │  ├── Scrape metrics from /metrics endpoints              │  │
│  │  ├── Store time-series data (retention: 15 days)         │  │
│  │  ├── Evaluate alerting rules                             │  │
│  │  ├── Send alerts to Alertmanager                         │  │
│  │  └── Provide PromQL query interface                      │  │
│  │                                                           │  │
│  │  Targets:                                                 │  │
│  │  ├── Django pods (django-app-prod:5000/metrics)          │  │
│  │  ├── Django pods (django-app-dev:5000/metrics)           │  │
│  │  ├── Kubernetes API server                               │  │
│  │  ├── Node exporter (worker nodes)                        │  │
│  │  └── cAdvisor (container metrics)                        │  │
│  └────────────────────┬─────────────────────────────────────┘  │
└─────────────────────────┼───────────────────────────────────────┘
                          │
                          │ Query & visualize
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Grafana Dashboard (monitoring namespace)       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Grafana                                                  │  │
│  │                                                           │  │
│  │  Dashboards:                                              │  │
│  │  ├── Django Application Metrics (ID: 9528)               │  │
│  │  │   ├── Request rate & latency                          │  │
│  │  │   ├── Error rates (4xx, 5xx)                          │  │
│  │  │   ├── Database query performance                      │  │
│  │  │   └── Cache hit ratio                                 │  │
│  │  │                                                        │  │
│  │  ├── Kubernetes Cluster Metrics                          │  │
│  │  │   ├── Pod CPU & memory usage                          │  │
│  │  │   ├── Pod restart counts                              │  │
│  │  │   ├── Node resource utilization                       │  │
│  │  │   └── Persistent volume usage                         │  │
│  │  │                                                        │  │
│  │  └── Infrastructure Metrics                              │  │
│  │      ├── RDS database metrics (via CloudWatch)           │  │
│  │      ├── Load balancer metrics                           │  │
│  │      └── Network traffic                                 │  │
│  │                                                           │  │
│  │  Features:                                                │  │
│  │  ├── Real-time visualizations                            │  │
│  │  ├── Custom alerts                                       │  │
│  │  ├── Historical analysis                                 │  │
│  │  └── User access control                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Key Metrics Monitored

#### Application Metrics (Django)

**HTTP Request Metrics:**
- `django_http_requests_total` - Total HTTP requests by method, status
- `django_http_requests_latency_seconds` - Request duration histogram
- `django_http_requests_body_total_bytes` - Request body size
- `django_http_responses_body_total_bytes` - Response body size

**Database Metrics:**
- `django_db_query_duration_seconds` - Query execution time
- `django_db_execute_total` - Total queries executed
- `django_db_execute_errors_total` - Failed queries

**Cache Metrics (Redis):**
- `django_cache_get_total` - Cache get operations
- `django_cache_get_hits_total` - Cache hits
- `django_cache_get_misses_total` - Cache misses
- Cache hit ratio: `(hits / (hits + misses)) * 100`

**Application Metrics:**
- `django_model_inserts_total` - Model insert operations
- `django_model_updates_total` - Model update operations
- `django_model_deletes_total` - Model delete operations

#### Infrastructure Metrics (Kubernetes)

**Pod Metrics:**
- `kube_pod_status_phase` - Pod lifecycle state
- `kube_pod_container_status_restarts_total` - Container restart count
- `container_cpu_usage_seconds_total` - CPU usage per container
- `container_memory_usage_bytes` - Memory usage per container

**Node Metrics:**
- `kube_node_status_condition` - Node health status
- `node_cpu_seconds_total` - Node CPU usage
- `node_memory_MemAvailable_bytes` - Available memory
- `node_disk_io_now` - Disk I/O operations

**Service Metrics:**
- `kube_service_status_load_balancer_ingress` - Load balancer status
- Service endpoint availability

#### Database Metrics (RDS via CloudWatch)
- CPU utilization
- Database connections
- Read/write IOPS
- Storage space
- Replication lag (if applicable)

### 6.3 Alerting Strategy

#### Alert Levels

**Critical (P1) - Immediate Response Required**
- Application completely down
- Database unavailable
- Disk space >95%
- Memory >95% for >5 minutes

**High (P2) - Response Within 1 Hour**
- Error rate >5%
- Response time >2 seconds (p95)
- Pod crash loops
- Database connection pool exhausted

**Medium (P3) - Response Within 4 Hours**
- Error rate >1%
- Response time >1 second (p95)
- Cache miss rate >30%
- High resource usage trends

**Low (P4) - Response Within 24 Hours**
- Slow queries detected
- Unusual traffic patterns
- Certificate expiring in <30 days

#### Sample Alert Rules

```yaml
# High error rate alert
- alert: HighErrorRate
  expr: rate(django_http_requests_total{status=~"5.."}[5m]) > 0.05
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High HTTP 5xx error rate detected"
    description: "{{ $value }}% of requests are failing"

# High response time alert
- alert: HighResponseTime
  expr: histogram_quantile(0.95, django_http_requests_latency_seconds) > 2
  for: 10m
  labels:
    severity: high
  annotations:
    summary: "API response time is high"
    description: "P95 latency is {{ $value }}s"

# Pod restart alert
- alert: PodRestarting
  expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
  for: 5m
  labels:
    severity: high
  annotations:
    summary: "Pod is restarting frequently"
    description: "Pod {{ $labels.pod }} has restarted {{ $value }} times"
```

### 6.4 Monitoring Deployment

#### Prerequisites
- Kubernetes cluster running
- kubectl configured
- Ansible installed

#### Deployment Steps

```bash
# 1. Deploy monitoring stack
cd ansible
ansible-playbook monitoring.yaml

# 2. Wait for pods to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s \
  deployment/grafana -n monitoring

# 3. Get access URLs
PROMETHEUS_URL=$(kubectl get svc prometheus-service -n monitoring \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
GRAFANA_URL=$(kubectl get svc grafana-service -n monitoring \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# 4. Get Grafana credentials
GRAFANA_PASSWORD=$(kubectl get secret grafana-credentials -n monitoring \
  -o jsonpath='{.data.admin-password}' | base64 --decode)

echo "Prometheus: http://$PROMETHEUS_URL:9090"
echo "Grafana: http://$GRAFANA_URL:3000"
echo "Username: admin"
echo "Password: $GRAFANA_PASSWORD"
```

#### Grafana Dashboard Setup

1. **Login to Grafana**
   - URL: http://<GRAFANA_URL>:3000
   - Username: admin
   - Password: (from secret)

2. **Add Prometheus Data Source**
   - Configuration → Data Sources → Add data source
   - Select: Prometheus
   - URL: http://prometheus-service:9090
   - Save & Test

3. **Import Django Dashboard**
   - Create → Import
   - Dashboard ID: 9528
   - Select: Prometheus data source
   - Import

4. **Create Custom Dashboards** (Optional)
   - Infrastructure overview
   - Business metrics
   - SLA compliance

### 6.5 Monitoring Best Practices

#### ✅ DO
1. **Set meaningful thresholds**
   - Based on SLA requirements
   - Account for normal variance
   - Test alert sensitivity

2. **Monitor what matters**
   - User-facing metrics first
   - Focus on actionable alerts
   - Track business KPIs

3. **Maintain dashboard hygiene**
   - Organize by purpose
   - Remove unused panels
   - Keep layouts consistent

4. **Document runbooks**
   - Link alerts to procedures
   - Include troubleshooting steps
   - Update after incidents

5. **Review regularly**
   - Tune alert thresholds
   - Add new metrics
   - Remove noise

#### ❌ DON'T
1. **Don't over-alert**
   - Causes alert fatigue
   - Reduces response urgency

2. **Don't ignore trends**
   - Monitor gradual degradation
   - Predict capacity issues

3. **Don't monitor in silos**
   - Correlate metrics
   - Understand dependencies

---

## 7. Deployment Workflows

### 7.1 Local Development Deployment

```bash
# 1. Clone repository
git clone <repository-url>
cd <repository-directory>

# 2. Create environment file
cat > .env << EOF
DB_NAME=carsdb
DB_USER=carsadmin
DB_PASSWORD=carspass
DB_HOST=db
DB_PORT=5432
EOF

# 3. Start services
docker compose up --build -d

# 4. Run migrations
docker compose exec app python manage.py migrate

# 5. Create superuser
docker compose exec app python manage.py createsuperuser

# 6. Access application
open http://localhost:5000
```

### 7.2 Production Deployment (Kubernetes)

```bash
# 1. Provision infrastructure
cd infra
terraform init
terraform plan
terraform apply

# 2. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name django-eks-cluster

# 3. Build and push image
docker build -t django-app:latest .
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_URL
docker tag django-app:latest $ECR_URL:latest
docker push $ECR_URL:latest

# 4. Deploy application
cd ../ansible
ansible-playbook playbook.yaml -e "deploy_env=prod db_password=<password>"

# 5. Verify deployment
kubectl get pods -n django-app-prod
kubectl get svc -n django-app-prod

# 6. Get application URL
kubectl get svc django-app-service -n django-app-prod \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### 7.3 Monitoring Deployment

```bash
# 1. Deploy monitoring stack
cd ansible
ansible-playbook monitoring.yaml

# 2. Access Grafana
kubectl get svc grafana-service -n monitoring

# 3. Configure dashboards
# Follow steps in section 6.4
```

### 7.4 Teardown Workflow

```bash
# 1. Delete Kubernetes resources
kubectl delete namespace django-app-prod
kubectl delete namespace django-app-dev
kubectl delete namespace monitoring

# 2. Wait for LoadBalancers to be deleted
# Check AWS console or CLI

# 3. Destroy infrastructure
cd infra
terraform destroy

# 4. Clean up local state
rm -rf .terraform
rm terraform.tfstate*
```

---

## 8. Testing Strategy

### 8.1 Testing Pyramid

```
                    ▲
                   ╱ ╲
                  ╱   ╲
                 ╱ E2E  ╲              Few, slow, expensive
                ╱       ╲
               ╱─────────╲
              ╱Integration╲            Some, medium speed
             ╱             ╲
            ╱───────────────╲
           ╱   Unit Tests    ╲        Many, fast, cheap
          ╱                   ╲
         ╱─────────────────────╲
```

### 8.2 Test Types

#### Unit Tests
**Coverage:** Individual functions, methods, classes  
**Framework:** Django Test Framework  
**Execution:** Local, CI pipeline

```bash
# Run all tests
python manage.py test

# Run specific app
python manage.py test cars

# Run with coverage
coverage run --source='.' manage.py test
coverage report
```

#### Integration Tests
**Coverage:** Component interactions, database operations  
**Framework:** Django Test Framework with TestCase  
**Database:** PostgreSQL test database

```python
# Example integration test
class CarModelTestCase(TestCase):
    def setUp(self):
        self.car = Car.objects.create(
            make="Toyota",
            model="Camry",
            year=2020
        )
    
    def test_car_creation(self):
        self.assertEqual(self.car.make, "Toyota")
        self.assertTrue(Car.objects.filter(model="Camry").exists())
```

#### End-to-End Tests (Future)
**Coverage:** Full user workflows  
**Framework:** Selenium, Playwright (not yet implemented)  
**Environment:** Staging environment

### 8.3 CI Testing

**GitHub Actions Service:**
```yaml
services:
  postgres:
    image: postgres:15-alpine
    env:
      POSTGRES_DB: test_db
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
```

**Test Execution:**
1. PostgreSQL service starts
2. Application connects to test database
3. Migrations run automatically
4. Unit and integration tests execute
5. Coverage report generated
6. Test database destroyed

### 8.4 Performance Testing (Future)

**Tools:**
- Locust for load testing
- JMeter for stress testing
- Artillery for API testing

**Metrics to Track:**
- Requests per second
- Response time percentiles (p50, p95, p99)
- Error rates under load
- Resource utilization

---

## 9. Lessons Learned

### 9.1 Infrastructure Management

#### 1. Terraform State Management
**Challenge:** Multiple team members working on same infrastructure  
**Issue:** State file conflicts and locking issues  
**Solution:**
- Implemented S3 backend for remote state storage
- Added DynamoDB table for state locking
- Configured state encryption

**Lesson:** Always use remote state with locking for team environments. Local state is only suitable for individual learning/testing.

**Implementation:**
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-states-django-app"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

#### 2. EKS Cluster Sizing
**Challenge:** Initial cluster too small for workload  
**Issue:** Pods stuck in Pending state due to insufficient resources  
**Solution:**
- Analyzed pod resource requests and limits
- Right-sized worker nodes (t3.small → t3.medium for some workloads)
- Implemented cluster autoscaling

**Lesson:** Monitor actual resource usage and adjust node sizes accordingly. Start with monitoring before scaling up.

#### 3. Networking Configuration
**Challenge:** Pods couldn't reach RDS database  
**Issue:** Security group rules too restrictive  
**Solution:**
- Updated security groups to allow EKS worker node security group
- Verified route tables and subnet associations
- Tested connectivity from pod using PostgreSQL client

**Lesson:** Test network connectivity early in infrastructure setup. Use `kubectl exec` to debug from within pods.

**Debug Command:**
```bash
kubectl run -it --rm debug --image=postgres:15-alpine --restart=Never -- \
  psql -h <rds-endpoint> -U postgres -d djangodb
```

### 9.2 Container & Kubernetes

#### 4. Image Build Optimization
**Challenge:** Docker images taking 5+ minutes to build  
**Issue:** Installing dependencies on every build  
**Solution:**
- Implemented multi-stage builds
- Leveraged Docker layer caching
- Optimized Dockerfile instruction order

**Lesson:** Put frequently changing files (source code) at the end of Dockerfile. Dependencies change less often and should be cached.

**Optimized Dockerfile:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app

# Install system dependencies (cached)
RUN apt-get update && apt-get install -y libpq-dev gcc

# Install Python dependencies (cached unless requirements.txt changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code (changes frequently)
COPY . .

CMD python manage.py migrate && python manage.py runserver 0.0.0.0:5000
```

#### 5. Health Checks
**Challenge:** Pods marked ready before application was serving traffic  
**Issue:** Requests hitting pods before Django fully started  
**Solution:**
- Implemented liveness and readiness probes
- Added startup delay to account for initialization time
- Used TCP socket checks for simplicity

**Lesson:** Always configure both liveness and readiness probes. Readiness prevents traffic to unready pods, liveness restarts unhealthy pods.

**Configuration:**
```yaml
livenessProbe:
  tcpSocket:
    port: 5000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  tcpSocket:
    port: 5000
  initialDelaySeconds: 10
  periodSeconds: 5
```

#### 6. Resource Limits
**Challenge:** Pods consuming excessive memory and causing node pressure  
**Issue:** No resource limits set, Django processes grew unbounded  
**Solution:**
- Set memory requests and limits based on monitoring
- Configured CPU requests for proper scheduling
- Implemented pod autoscaling based on CPU

**Lesson:** Always set resource requests and limits. Requests ensure QoS, limits prevent resource hogging.

### 9.3 CI/CD & Automation

#### 7. Pipeline Failures Due to Linting
**Challenge:** Pipeline failing on Django migration files  
**Issue:** Flake8 checking auto-generated migration files  
**Solution:**
- Created .flake8 configuration file
- Excluded migrations directory
- Excluded other auto-generated files

**Lesson:** Configure linters to respect framework conventions. Not all code should be linted the same way.

**.flake8 Configuration:**
```ini
[flake8]
exclude = 
    migrations/,
    __pycache__,
    venv/,
    .git/
max-line-length = 120
```

#### 8. Ansible Idempotency
**Challenge:** Re-running playbook caused duplicate resources  
**Issue:** Using `kubectl create` instead of `kubectl apply`  
**Solution:**
- Switched to `kubectl apply` for idempotent operations
- Used `--dry-run=client -o yaml | kubectl apply` for secrets
- Added check tasks before create operations

**Lesson:** Ansible tasks should be idempotent. Use declarative approaches (apply) over imperative (create).

#### 9. Secret Management in CI
**Challenge:** Database password exposed in CI logs  
**Issue:** Echoing environment variables in debug steps  
**Solution:**
- Removed debug prints of sensitive values
- Masked secrets in GitHub Actions
- Used secret references instead of values

**Lesson:** Never print secrets in logs. Use secret masking features of CI platforms.

### 9.4 Monitoring & Debugging

#### 10. Prometheus Scrape Failures
**Challenge:** Prometheus not collecting Django metrics  
**Issue:** Incorrect service discovery annotation  
**Solution:**
- Fixed pod annotations for Prometheus scraping
- Verified /metrics endpoint was accessible
- Checked Prometheus targets page

**Lesson:** Verify monitoring setup early. Check Prometheus targets page to confirm scraping is working.

**Correct Annotations:**
```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "5000"
    prometheus.io/path: "/metrics"
```

#### 11. Dashboard Overwhelm
**Challenge:** Too many dashboards with duplicate information  
**Issue:** Created dashboard for every metric without planning  
**Solution:**
- Consolidated related metrics into single dashboards
- Created role-based dashboard views (developer, ops, business)
- Removed unused panels

**Lesson:** Quality over quantity in dashboards. Focus on actionable insights, not vanity metrics.

### 9.5 Database Management

#### 12. Migration Failures in Production
**Challenge:** Migrations failing during deployment  
**Issue:** Schema changes conflicting with running application  
**Solution:**
- Implemented backward-compatible migrations
- Separated data and schema migrations
- Added migration validation step in CI

**Lesson:** Always make migrations backward compatible. Use multi-step deployments for breaking changes.

#### 13. Connection Pool Exhaustion
**Challenge:** "Too many connections" errors under load  
**Issue:** Default Django database connection settings  
**Solution:**
- Configured CONN_MAX_AGE for connection pooling
- Set appropriate pool size
- Monitored connection count

**Lesson:** Configure connection pooling for production. Don't rely on defaults.

**Django Settings:**
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'CONN_MAX_AGE': 60,  # Connection pooling
        'OPTIONS': {
            'connect_timeout': 10,
        }
    }
}
```

#### 14. Data Seeding
**Challenge:** Production environment had no initial data  
**Issue:** Forgot to run data import after deployment  
**Solution:**
- Created Django management command for data seeding
- Added seed step to deployment playbook
- Made seeding idempotent

**Lesson:** Automate data seeding as part of deployment. Don't rely on manual steps.

**Management Command:**
```python
# cars/management/commands/load_init_data.py
from django.core.management.base import BaseCommand
from cars.models import Car

class Command(BaseCommand):
    def handle(self, *args, **options):
        # Idempotent data loading
        if not Car.objects.exists():
            Car.objects.create(make="Toyota", model="Camry", year=2020)
            # ... more data
```

### 9.6 Security

#### 15. Exposed Secrets in Git History
**Challenge:** API key accidentally committed  
**Issue:** Secret committed in early commit  
**Solution:**
- Rotated exposed secret immediately
- Used git filter-branch to remove from history
- Implemented pre-commit hooks to prevent future incidents

**Lesson:** Assume any secret in Git history is compromised. Rotate immediately, don't just delete the commit.

**Prevention:**
```bash
# Install pre-commit hooks
pip install pre-commit detect-secrets
pre-commit install

# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    hooks:
      - id: detect-secrets
```

#### 16. Container Image Vulnerabilities
**Challenge:** Security scan found critical vulnerabilities  
**Issue:** Using outdated base image  
**Solution:**
- Updated to latest slim base image
- Implemented automated scanning in CI
- Set up vulnerability monitoring

**Lesson:** Regularly update base images and scan for vulnerabilities. Automate scanning in CI pipeline.

---

## 10. Best Practices & Recommendations

### 10.1 Infrastructure

✅ **Use Infrastructure as Code**
- Version control all infrastructure
- Review infrastructure changes like code
- Test infrastructure changes in dev first

✅ **Implement Multi-Environment Strategy**
- Separate dev, staging, prod environments
- Use namespace isolation in Kubernetes
- Environment-specific configurations

✅ **Enable Autoscaling**
- Horizontal Pod Autoscaler for applications
- Cluster autoscaling for nodes
- Monitor and tune scaling thresholds

✅ **Backup Everything**
- Automated RDS backups
- etcd backups for Kubernetes
- Configuration backups

### 10.2 Application

✅ **Follow 12-Factor App Principles**
- Externalize configuration
- Treat logs as streams
- Disposable processes
- Dev/prod parity

✅ **Implement Graceful Shutdown**
- Handle SIGTERM signals
- Finish in-flight requests
- Close database connections

✅ **Use Health Checks**
- Liveness probes to detect crashes
- Readiness probes for traffic management
- Startup probes for slow-starting apps

### 10.3 Security

✅ **Principle of Least Privilege**
- Minimal IAM permissions
- RBAC in Kubernetes
- Network policies

✅ **Encrypt Everything**
- TLS for all external communication
- Encryption at rest for databases
- Encrypted secrets in Kubernetes

✅ **Regular Security Audits**
- Automated vulnerability scanning
- Dependency updates
- Security patch management

### 10.4 Monitoring

✅ **Monitor SLIs/SLOs**
- Define service level indicators
- Set service level objectives
- Track error budgets

✅ **Alert on Symptoms, Not Causes**
- Alert on user-facing issues
- Use metrics that matter to users
- Avoid alert fatigue

✅ **Implement Observability**
- Metrics (Prometheus)
- Logs (centralized logging)
- Traces (distributed tracing - future)

### 10.5 CI/CD

✅ **Automate Everything**
- Tests run on every commit
- Deployments triggered by merges
- Rollbacks automated

✅ **Fast Feedback Loops**
- Quick test execution
- Parallel pipeline stages
- Clear error messages

✅ **Progressive Delivery**
- Canary deployments
- Feature flags
- Gradual rollouts

---

## Conclusion

This DevOps implementation demonstrates enterprise-grade practices for deploying Django applications in production environments. The project successfully implements:

- **Automated infrastructure provisioning** using Terraform
- **Container orchestration** on Kubernetes (AWS EKS)
- **Comprehensive CI/CD** pipeline with GitHub Actions
- **Production-grade monitoring** with Prometheus and Grafana
- **Secure secret management** across all environments
- **High availability** through multi-replica deployments

### Key Achievements

1. **Infrastructure as Code:** 100% of infrastructure defined in Terraform
2. **Automation:** Zero-touch deployments from code commit to production
3. **Observability:** Real-time monitoring with custom dashboards
4. **Security:** No secrets in code, encrypted at rest, scanned for vulnerabilities
5. **Scalability:** Auto-scaling enabled at both application and infrastructure layers

### Future Enhancements

1. **Service Mesh:** Implement Istio for advanced traffic management
2. **Advanced Monitoring:** Add distributed tracing with Jaeger
3. **Disaster Recovery:** Implement multi-region deployment
4. **Cost Optimization:** Right-sizing and reserved instances
5. **Advanced Security:** WAF, DDoS protection, secrets rotation automation

---

**Project Repository:** https://github.com/haq2682/Django-PostgreSQL_Final-Exam  
**Documentation:** README.md  
**Last Updated:** December 2024
