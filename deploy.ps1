# Kubernetes Deployment Script for Task 2 (PowerShell)
# This script deploys the complete application stack to Kubernetes

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Kaiburr Task 2 - Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is available
try {
    kubectl version --client --short 2>$null | Out-Null
    Write-Host "✓ kubectl found" -ForegroundColor Green
} catch {
    Write-Host "ERROR: kubectl is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if cluster is accessible
try {
    kubectl cluster-info 2>$null | Out-Null
    Write-Host "✓ Connected to Kubernetes cluster" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Cannot connect to Kubernetes cluster" -ForegroundColor Red
    Write-Host "Make sure minikube/kind is running or kubeconfig is set" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 1: Create RBAC resources
Write-Host "Step 1: Creating RBAC resources (ServiceAccount, Role, RoleBinding)..." -ForegroundColor Yellow
kubectl apply -f k8s/rbac.yaml
Write-Host "✓ RBAC resources created" -ForegroundColor Green
Write-Host ""

# Step 2: Create MongoDB PV and PVC
Write-Host "Step 2: Creating MongoDB Persistent Volume and Claim..." -ForegroundColor Yellow
kubectl apply -f k8s/mongodb-pvc.yaml
Write-Host "✓ MongoDB PV and PVC created" -ForegroundColor Green
Write-Host ""

# Step 3: Deploy MongoDB
Write-Host "Step 3: Deploying MongoDB..." -ForegroundColor Yellow
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb-service.yaml
Write-Host "✓ MongoDB deployment and service created" -ForegroundColor Green
Write-Host ""

# Step 4: Wait for MongoDB to be ready
Write-Host "Step 4: Waiting for MongoDB to be ready (timeout: 120s)..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s
Write-Host "✓ MongoDB is ready" -ForegroundColor Green
Write-Host ""

# Step 5: Deploy Task API application
Write-Host "Step 5: Deploying Task API application..." -ForegroundColor Yellow
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml
Write-Host "✓ Task API deployment and service created" -ForegroundColor Green
Write-Host ""

# Step 6: Wait for application to be ready
Write-Host "Step 6: Waiting for Task API to be ready (timeout: 180s)..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=task-api --timeout=180s
Write-Host "✓ Task API is ready" -ForegroundColor Green
Write-Host ""

# Step 7: Display deployment status
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pods:" -ForegroundColor Yellow
kubectl get pods
Write-Host ""
Write-Host "Services:" -ForegroundColor Yellow
kubectl get svc
Write-Host ""

# Get the NodePort URL
$nodeInfo = kubectl get nodes -o json | ConvertFrom-Json
$nodeIP = $nodeInfo.items[0].status.addresses | Where-Object { $_.type -eq "InternalIP" } | Select-Object -ExpandProperty address

$serviceInfo = kubectl get svc task-api-service -o json | ConvertFrom-Json
$nodePort = $serviceInfo.spec.ports[0].nodePort

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Access the API at:" -ForegroundColor Green
Write-Host "http://${nodeIP}:${nodePort}/tasks" -ForegroundColor Cyan
Write-Host ""
Write-Host "If using Minikube, run:" -ForegroundColor Yellow
Write-Host "minikube service task-api-service --url" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
