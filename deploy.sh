#!/bin/bash
# Kubernetes Deployment Script for Task 2
# This script deploys the complete application stack to Kubernetes

set -e

echo "========================================="
echo "Kaiburr Task 2 - Kubernetes Deployment"
echo "========================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "ERROR: Cannot connect to Kubernetes cluster"
    echo "Make sure minikube/kind is running or kubeconfig is set"
    exit 1
fi

echo "✓ Connected to Kubernetes cluster"
echo ""

# Step 1: Create RBAC resources
echo "Step 1: Creating RBAC resources (ServiceAccount, Role, RoleBinding)..."
kubectl apply -f k8s/rbac.yaml
echo "✓ RBAC resources created"
echo ""

# Step 2: Create MongoDB PV and PVC
echo "Step 2: Creating MongoDB Persistent Volume and Claim..."
kubectl apply -f k8s/mongodb-pvc.yaml
echo "✓ MongoDB PV and PVC created"
echo ""

# Step 3: Deploy MongoDB
echo "Step 3: Deploying MongoDB..."
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb-service.yaml
echo "✓ MongoDB deployment and service created"
echo ""

# Step 4: Wait for MongoDB to be ready
echo "Step 4: Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s
echo "✓ MongoDB is ready"
echo ""

# Step 5: Deploy Task API application
echo "Step 5: Deploying Task API application..."
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml
echo "✓ Task API deployment and service created"
echo ""

# Step 6: Wait for application to be ready
echo "Step 6: Waiting for Task API to be ready..."
kubectl wait --for=condition=ready pod -l app=task-api --timeout=180s
echo "✓ Task API is ready"
echo ""

# Step 7: Display deployment status
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Pods:"
kubectl get pods
echo ""
echo "Services:"
kubectl get svc
echo ""

# Get the NodePort URL
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl get svc task-api-service -o jsonpath='{.spec.ports[0].nodePort}')

echo "========================================="
echo "Access the API at:"
echo "http://$NODE_IP:$NODE_PORT/tasks"
echo ""
echo "If using Minikube, run: minikube service task-api-service --url"
echo "========================================="
