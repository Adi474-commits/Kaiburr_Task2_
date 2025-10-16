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
![Persistent Volume](screenshots/task2/03_persistent_volume.png)

#### 4. Application Endpoint Available from Host
**Shows:** API accessible via curl/Invoke-RestMethod from host machine
```powershell
Invoke-RestMethod -Uri "http://<node-ip>:30080/tasks"
```
![Endpoint Available](screenshots/task2/04_endpoint_from_host.png)

#### 5. ⭐ Execute Creates Kubernetes Pod (MOST IMPORTANT!)
**Shows:** PUT /tasks/{id}/execute creating a new pod programmatically
```powershell
# Terminal 1: kubectl get pods --watch
# Terminal 2: Invoke-RestMethod -Method Put -Uri "$API_URL/tasks/$taskId/execute"
```
![Execute Creates Pod](screenshots/task2/05_execute_creates_pod.png)

**This screenshot proves the key requirement: commands run in Kubernetes pods, not locally!**

#### 6. Execution Pod Uses Busybox Image
**Shows:** Execution pod details with busybox:latest image
```powershell
kubectl describe pod <task-exec-pod-name>
```
![Busybox Execution Pod](screenshots/task2/06_busybox_pod.png)

#### 7. Execution Pod Logs (Command Output)
**Shows:** Logs from execution pod containing command output
```powershell
kubectl logs <task-exec-pod-name>
```
![Execution Pod Logs](screenshots/task2/07_execution_logs.png)

#### 8. MongoDB Pod Environment Variables
**Shows:** MongoDB pod takes configuration from environment
```powershell
kubectl describe pod -l app=mongodb
```
![MongoDB Environment](screenshots/task2/08_mongodb_env.png)

#### 9. Task API Pod Environment Variables
**Shows:** App reads MONGO_HOST, MONGO_PORT from environment
```powershell
kubectl describe pod -l app=task-api
```
![Task API Environment](screenshots/task2/09_task_api_env.png)

#### 10. Task Execution History in Database
**Shows:** TaskExecution saved in MongoDB with output, times, exit code
```powershell
Invoke-RestMethod -Uri "$API_URL/tasks/$taskId"
```
![Execution History](screenshots/task2/10_execution_history.png)

#### 11. Data Persists After MongoDB Pod Deletion
**Shows:** Delete MongoDB pod → new pod starts → data still exists
```powershell
kubectl delete pod -l app=mongodb
# Wait for new pod
Invoke-RestMethod -Uri "$API_URL/tasks"
```
![Data Persistence](screenshots/task2/11_data_persistence.png)




---




