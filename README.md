# Kaiburr Assessment: # Task 2: Kubernetes Deployment

**Submitted by: Adithya N Reddy**  
**Program:** B.Tech, Amrita School of Engineering, Bengaluru  
**Branch:** Electronics and Computer Engineering  
**Enrollment:** BL.EN.U4EAC22075  
**Email:** adithyasnr@gmail.com

---

# Task 2: Kubernetes Deployment

## Overview

Task 2 extends Task 1 by deploying the application to Kubernetes with the following key changes:

### Key Features

1) **Pod-Based Execution**: Commands execute in ephemeral Kubernetes pods (busybox image)  
2) **Kubernetes Client**: Uses Fabric8 Kubernetes Java client v6.9.2  
3) **Containerized App**: Spring Boot runs in Docker container  
4) **MongoDB on K8s**: Deployed with PersistentVolume for data persistence  
5) **RBAC**: ServiceAccount with pod creation/deletion permissions  
6) **Environment Config**: MongoDB connection via env variables  
7) **Auto Cleanup**: Execution pods deleted after command completion  

### Architecture

```
Kubernetes Cluster
├── Task API Pod (Spring Boot)
│   ├── Creates execution pods dynamically
│   ├── Waits for completion
│   └── Captures logs & exit codes
├── MongoDB Pod (with PersistentVolume)
└── Execution Pods (busybox, ephemeral)
    └── Run commands and auto-delete
```

### How It Works

1. Client calls `PUT /tasks/{id}/execute`
2. Task API reads command from MongoDB
3. Task API creates new Kubernetes pod with busybox image
4. Pod runs command (e.g., `date`, `hostname`, `echo`)
5. Task API waits for pod completion (max 300s)
6. Task API retrieves pod logs as output
7. Task API records execution details in MongoDB
8. Task API deletes the execution pod
9. Client receives TaskExecution response

## Quick Start (Task 2)

### Prerequisites
- Docker
- Kubernetes (Minikube/Kind/Docker Desktop)
- kubectl

### Build and Deploy

```powershell
# 1. Build Docker image
.\build.ps1

# 2. Load image to Kubernetes (if using Minikube)
minikube docker-env | Invoke-Expression
docker build -t kaiburr-task-api:latest .

# 3. Deploy to Kubernetes
.\deploy.ps1

# 4. Get API URL
minikube service task-api-service --url

# 5. Test API
$API_URL = "http://localhost:30080"
Invoke-RestMethod -Method Put -Uri "$API_URL/tasks" `
  -ContentType "application/json" `
  -Body '{"name":"Date Task","owner":"Adithya N Reddy","command":"date"}'
```

## Documentation

### Key Files

| File | Purpose |
|------|---------|
| `k8s/mongodb-pvc.yaml` | PersistentVolume + PVC for MongoDB |
| `k8s/mongodb-deployment.yaml` | MongoDB deployment |
| `k8s/mongodb-service.yaml` | MongoDB ClusterIP service |
| `k8s/rbac.yaml` | ServiceAccount, Role, RoleBinding |
| `k8s/app-deployment.yaml` | Task API deployment |
| `k8s/app-service.yaml` | Task API NodePort service (port 30080) |
| `Dockerfile` | Multi-stage Docker build |
| `deploy.ps1` | Automated deployment script |
| `src/.../KubernetesExecutorService.java` | Pod execution logic |

## Testing Task 2

```powershell
# Watch pods while executing tasks
kubectl get pods --watch

# In another terminal, execute a task
$API_URL = "http://localhost:30080"
$task = Invoke-RestMethod -Method Put -Uri "$API_URL/tasks" `
  -ContentType "application/json" `
  -Body '{"name":"Hostname","owner":"Adithya N Reddy","command":"hostname"}'

Invoke-RestMethod -Method Put -Uri "$API_URL/tasks/$($task.id)/execute"

# You will see an execution pod appear and complete:
# task-exec-xxxxxxxx-yyyymmdd-hhmmss
```

## Task 2 Kubernetes Deployment Screenshots

*All screenshots show Kubernetes deployment with system date/time visible for verification.*

### Required Proof Screenshots

#### 1. Kubernetes Cluster and Pods Running
**Shows:** MongoDB in separate pod, Task API pod, both running
```powershell
kubectl get pods -o wide
```
<img width="1161" height="393" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com" src="https://github.com/user-attachments/assets/278fd747-c169-4c52-84c9-9f46b7111a25" />

#### 2. Services Exposed (NodePort)
**Shows:** NodePort service exposing API on port 30080
```powershell
kubectl get svc
```
<img width="1161" height="393" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (1)" src="https://github.com/user-attachments/assets/45acabef-1a53-4f79-ab51-e38cd50781ea" />



#### 3. Persistent Volume for MongoDB
**Shows:** PV and PVC bound for MongoDB data persistence
```powershell
kubectl get pv,pvc
```
<img width="1161" height="241" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (2)" src="https://github.com/user-attachments/assets/4c771661-1a1f-4613-9f80-9b515437220a" />


#### 4. Application Endpoint Available from Host
**Shows:** API accessible via curl/Invoke-RestMethod from host machine
```powershell
Invoke-RestMethod -Uri "http://<node-ip>:30080/tasks"
```
<img width="1161" height="222" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (3)" src="https://github.com/user-attachments/assets/ceea77d0-8983-4774-be26-73dc8f8f2790" />


#### 5. ⭐ Execute Creates Kubernetes Pod (MOST IMPORTANT!)
**Shows:** PUT /tasks/{id}/execute creating a new pod programmatically
```powershell
# Terminal 1: kubectl get pods --watch
# Terminal 2: Invoke-RestMethod -Method Put -Uri "$API_URL/tasks/$taskId/execute"
```
<img width="1161" height="288" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (4)" src="https://github.com/user-attachments/assets/f3a304ed-fcb2-4a49-a4ad-ea98576486c1" />

<img width="1161" height="292" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (5)" src="https://github.com/user-attachments/assets/406e4f6f-1a5d-4106-bad1-9f6ea0705a8d" />

**This screenshot proves the key requirement: commands run in Kubernetes pods, not locally!**

#### 6. Execution Pod Uses Busybox Image
**Shows:** Execution pod details with busybox:latest image
```powershell
kubectl describe pod <task-exec-pod-name>
```
<img width="1161" height="283" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (6)" src="https://github.com/user-attachments/assets/2822b21b-61cc-4cee-9482-76ac74226ba7" />


#### 7. Execution Pod Logs (Command Output)
**Shows:** Logs from execution pod containing command output
```powershell
kubectl logs <task-exec-pod-name>
```
<img width="1161" height="259" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (7)" src="https://github.com/user-attachments/assets/4bffb6f5-59e2-4854-beaf-a150b7612526" />


#### 8. MongoDB Pod Environment Variables
**Shows:** MongoDB pod takes configuration from environment
```powershell
kubectl describe pod -l app=mongodb
```

<img width="1161" height="256" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (8)" src="https://github.com/user-attachments/assets/4ecf961e-6fd1-468b-9134-fff591bd9270" />


#### 9. Task API Pod Environment Variables
**Shows:** App reads MONGO_HOST, MONGO_PORT from environment
```powershell
kubectl describe pod -l app=task-api
```
<img width="1161" height="257" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (9)" src="https://github.com/user-attachments/assets/05fbc5e3-e24d-4f99-924c-b7a08cae299b" />


#### 10. Task Execution History in Database
**Shows:** TaskExecution saved in MongoDB with output, times, exit code
```powershell
Invoke-RestMethod -Uri "$API_URL/tasks/$taskId"
```
<img width="1161" height="334" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (10)" src="https://github.com/user-attachments/assets/3ab9642e-5de2-4500-8b8d-9c987e492497" />


#### 11. Data Persists After MongoDB Pod Deletion
**Shows:** Delete MongoDB pod → new pod starts → data still exists
```powershell
kubectl delete pod -l app=mongodb
# Wait for new pod
Invoke-RestMethod -Uri "$API_URL/tasks"
```
<img width="703" height="379" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (11)" src="https://github.com/user-attachments/assets/c282fbc4-21d7-4945-bd8a-fe9b9ab747e3" />

<img width="654" height="376" alt="ADITHYA REDDY 16102025 adithyasnr@gmail com (12)" src="https://github.com/user-attachments/assets/503b666c-bfd4-4c65-914f-cb2361685916" />







---








