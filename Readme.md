# Scalable Kubernetes Upload Microservice Architecture (Laravel + Horizon + S3 + EKS)

This project implements a production-ready, scalable architecture for a Laravel microservice that handles asynchronous file uploads using Laravel Horizon and Amazon S3.  
The solution leverages **Kubernetes (EKS), Redis (ElastiCache), S3, KEDA, IRSA, and Helm-based observability**.

The goal was to improve:

- scalability  
- reliability  
- fault tolerance  

**without modifying application business logic.**

---

## 🏗 Architecture Overview

![alt text](<Architecture overview.png>)


## 🚀 Components

### Laravel API
Handles upload requests and publishes jobs to Redis.

### Laravel Horizon Workers
Process queued jobs and move files from temporary S3 bucket → final S3 bucket.

### Redis (AWS ElastiCache)
Highly available queue backend.

### Amazon S3
Primary storage — ensures stateless services with high durability.

### KEDA
Scales Horizon workers based on queue backlog.

### IRSA
Grants AWS permissions securely using IAM roles instead of static credentials.

## 🔐 Security
No static AWS keys in Kubernetes Secrets

IAM Roles for Service Accounts enforce least-privilege

S3 access restricted to specific buckets only

## 📦 Project Structure
```
Copy code
terraform/                 # Infrastructure (EKS, networking, IAM, Redis, etc.)
kubernetes/
  base/                    # Common K8s resources (SA, secrets, config)
  api/                     # API Deployment, Service, HPA, Ingress
  horizon/                 # Worker Deployment, KEDA autoscaling
  observability/           # Helm values files for monitoring stack
```

### ⚠️ Important: Replace Placeholders Before Deploying
A few configuration values must be updated to match your AWS environment.

#### 1️⃣ Set your Redis (ElastiCache) endpoint
Edit both:
```
kubernetes/base/configmap.yaml

kubernetes/base/secrets.yaml
```
Replace:

```
<upload-service-redis.xxxxxx.use1.cache.amazonaws.com>
```
with your actual Redis primary endpoint (found in AWS Console → ElastiCache → Redis).

#### 2️⃣ Set your S3 bucket names
Edit:
```
kubernetes/base/secrets.yaml
```
Update:

```
AWS_BUCKET: your-bucket
```
Use your real S3 bucket name.

#### 3️⃣ Set the API container image
Edit:
```
kubernetes/api/deployment.yaml
```
Set:
```
image: your-dockerhub-username/laravel-api:latest
```
(or your ECR image URI).

#### 4️⃣ Configure Ingress host and TLS certificate
Edit:
 ```
kubernetes/api/ingress.yaml
```
Replace:

```
api.example.com
<certificate-arn>
```
with your domain and ACM certificate ARN (in the same region as EKS).

Once these values are updated, continue with deployment.

## ⚙️ Deployment Instructions
### 1️⃣ Provision Infrastructure (Terraform)
```
cd terraform
terraform init
terraform plan
terraform apply
```
## Terraform provisions:

- EKS cluster

- ElastiCache Redis

- IAM role for IRSA

- networking resources

### 2️⃣ Configure kubectl
```
aws eks update-kubeconfig --name <cluster-name> --region <region>
```
### 3️⃣ Deploy Base Resources
```
kubectl apply -f kubernetes/base
```

## Deploys

- namespaces  
- service accounts  
- configmaps  
- secrets

### 4️⃣ Deploy Laravel API
```
kubectl apply -f kubernetes/api
```
Creates:

Deployment

Service

Ingress

HPA

### 5️⃣ Deploy Horizon Workers
```
kubectl apply -f kubernetes/horizon
```
KEDA automatically scales workers based on Redis queue depth.

## 📊 Observability (Helm)
```
kubectl create namespace observability

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
#### Install Prometheus
```
helm install prometheus prometheus-community/prometheus \
  -n observability \
  -f kubernetes/observability/values-prometheus.yaml
  ```
#### Install Grafana
```
helm install grafana grafana/grafana \
  -n observability \
  -f kubernetes/observability/values-grafana.yaml
  ```
#### Install Loki (Logs)
```
helm install loki grafana/loki-stack \
  -n observability \
  -f kubernetes/observability/values-loki.yaml
  ```
#### Retrieve Grafana admin password:

```
kubectl get secret grafana -n observability -o jsonpath="{.data.admin-password}" | base64 --decode
```
## 🧪 Validation Checklist
Check pods:

```
kubectl get pods -A
```
Check API autoscaling:
```
kubectl get hpa -n uploads
```
Check worker autoscaling:

```
kubectl get scaledobject -n uploads
```
Check Ingress:

```
kubectl get ingress -n uploads
```