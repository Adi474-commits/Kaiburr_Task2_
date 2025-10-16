# Kaiburr Assessment: Java REST API & Kubernetes

This repository contains solutions for Kaiburr Assessment Tasks 1 and 2:

- **Task 1:** Java REST API with MongoDB (local command execution)
- **Task 2:** Kubernetes deployment with pod-based command execution

**Submitted by: Adithya N Reddy**  
**Program:** B.Tech, Amrita School of Engineering, Bengaluru  
**Branch:** Electronics and Computer Engineering  
**Enrollment:** BL.EN.U4EAC22075  
**Email:** adithyasnr@gmail.com

---

## 📂 Project Structure

```
Task_1/
├── src/                          # Java source code
├── k8s/                          # Kubernetes manifests
│   ├── mongodb-pvc.yaml         # MongoDB persistent storage
│   ├── mongodb-deployment.yaml  # MongoDB deployment
│   ├── mongodb-service.yaml     # MongoDB service
│   ├── rbac.yaml                # RBAC for pod creation
│   ├── app-deployment.yaml      # Task API deployment
│   └── app-service.yaml         # Task API service (NodePort)
├── screenshots/                  # API demonstration screenshots
├── Dockerfile                    # Multi-stage Docker build
├── docker-compose.yml           # Local MongoDB (Task 1)
├── deploy.ps1                   # Kubernetes deployment script
├── build.ps1                    # Docker image build script
├── README.md                    # This file (overview)
├── TASK2_README.md              # Detailed Task 2 documentation
└── TASK2_TESTING_GUIDE.md       # Testing and screenshot guide
```

---

## 🚀 Quick Start

### Task 1: Local REST API
See section below or [Task 1 Documentation](#task-1-java-rest-api)

### Task 2: Kubernetes Deployment
1. Build Docker image: `.\build.ps1`
2. Deploy to Kubernetes: `.\deploy.ps1`
3. See **[TASK2_README.md](TASK2_README.md)** for complete instructions

---

# Task 1: Java REST API

This is a production-ready Java Spring Boot application that exposes REST endpoints to create, manage, and execute shell command "tasks". It uses MongoDB for data persistence and includes robust validation and error handling.

## Features

-   **CRUD Operations:** Full Create, Read, Update, Delete functionality for tasks.
-   **Task Search:** Search for tasks by name (substring matching).
-   **Secure Command Execution:** Executes whitelisted shell commands (`echo`, `date`, `uname`, etc.) and records the output and timestamps.
-   **Command Validation:** Prevents execution of unsafe commands or commands with shell metacharacters.
-   **MongoDB Persistence:** Uses an embedded document model to store task execution history.
-   **RESTful API:** Follows standard REST principles with appropriate HTTP verbs and status codes.

---

## Tech Stack

-   **Backend:** Java 17, Spring Boot 3
-   **Database:** MongoDB
-   **Build Tool:** Apache Maven
-   **Containerization:** Docker

---

## Local Setup

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-folder>
    ```

2.  **Start the MongoDB database using Docker:**
    Open a terminal in the project root and run:
    ```bash
    docker-compose up -d
    ```
    This will start a MongoDB container and expose it on port `27017`.

3.  **Run the Spring Boot Application:**
    In the same terminal, run the application using Maven Wrapper:
    ```bash
    .\mvnw.cmd spring-boot:run
    ```
    The API server will start on `http://localhost:8081`.

---

## API Reference

The base URL for all endpoints is `http://localhost:8081`.

### 1. Create or Update a Task
-   **Endpoint:** `PUT /tasks`
-   **`curl` Example:**
    ```bash
    curl -X PUT http://localhost:8081/tasks -H "Content-Type: application/json" -d '{"name": "System Info Task", "owner": "Your Name", "command": "uname -a"}'
    ```

### 2. Get All Tasks or a Single Task
-   **Endpoint:** `GET /tasks` or `GET /tasks?id={taskId}`
-   **`curl` Examples:**
    ```bash
    # Get all tasks
    curl http://localhost:8081/tasks

    # Get a single task by its ID
    curl http://localhost:8081/tasks?id=<your_task_id>
    ```

### 3. Search Tasks by Name
-   **Endpoint:** `GET /tasks/search?name={substring}`
-   **`curl` Example:**
    ```bash
    curl "http://localhost:8081/tasks/search?name=Info"
    ```

### 4. Execute a Task
-   **Endpoint:** `PUT /tasks/{id}/execute`
-   **`curl` Example:**
    ```bash
    curl -X PUT http://localhost:8081/tasks/<your_task_id>/execute
    ```

### 5. Delete a Task
-   **Endpoint:** `DELETE /tasks/{id}`
-   **`curl` Example:**
    ```bash
    curl -X DELETE http://localhost:8081/tasks/<your_task_id>
    ```

---

## API Demonstration (Screenshots)

*All screenshots include the system date/time and task owner name for verification.*

### 1. Create a New Task
![Create Task](screenshots/01_create_task.png)
<br/>
**Owner / Timestamp (for verification):**
![Owner and Timestamp](screenshots/01_create_task_owner.png)

### 2. Attempt to Create a Task with an Unsafe Command
![Unsafe Command Blocked](screenshots/02_unsafe_command.png)
<br/>
**Owner / Timestamp (for verification):**
![Owner and Timestamp](screenshots/02_unsafe_command.png)

### 3. Get All Tasks
![Get All Tasks](screenshots/03_get_all_tasks_owner.png)
<br/>
**Owner / Timestamp (for verification):**
![Owner and Timestamp](screenshots/03_get_all_tasks_owner.png)

### 4. Search for a Task by Name
![Search Tasks](screenshots/04_search_tasks_owner.png)
<br/>
**Owner / Timestamp (for verification):**
![Owner and Timestamp](screenshots/04_search_tasks_owner.png)

### 5. Execute a Task
![Execute Task](screenshots/05_execute_task_owner.png)
<br/>
**Owner / Timestamp (for verification):**
![Owner and Timestamp](screenshots/05_execute_task_owner.png)

### 6. Verify Task Execution History
![Task Execution History](screenshots/06_execution_history_owner.png)
<br/>
**Owner / Timestamp (for verification):**
![Owner and Timestamp](screenshots/06_execution_history_owner.png)

---

# Task 2: Kubernetes Deployment

## Overview

Task 2 extends Task 1 by deploying the application to Kubernetes with the following key changes:

### Key Features

✅ **Pod-Based Execution**: Commands execute in ephemeral Kubernetes pods (busybox image)  
✅ **Kubernetes Client**: Uses Fabric8 Kubernetes Java client v6.9.2  
✅ **Containerized App**: Spring Boot runs in Docker container  
✅ **MongoDB on K8s**: Deployed with PersistentVolume for data persistence  
✅ **RBAC**: ServiceAccount with pod creation/deletion permissions  
✅ **Environment Config**: MongoDB connection via env variables  
✅ **Auto Cleanup**: Execution pods deleted after command completion  

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

📖 **Complete Task 2 documentation**: [TASK2_README.md](TASK2_README.md)  
📖 **Testing guide with screenshots**: [TASK2_TESTING_GUIDE.md](TASK2_TESTING_GUIDE.md)

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
![Pods Running](screenshots/task2/01_pods_running.png)

#### 2. Services Exposed (NodePort)
**Shows:** NodePort service exposing API on port 30080
```powershell
kubectl get svc
```
![Services](screenshots/task2/02_services.png)

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

#### 12. RBAC Configuration
**Shows:** ServiceAccount with pod creation permissions
```powershell
kubectl describe role task-api-role
kubectl describe rolebinding task-api-rolebinding
```
![RBAC](screenshots/task2/12_rbac.png)

---

### How to Generate These Screenshots

Run the automated screenshot demo script:

```powershell
# Get your API URL first
$API_URL = minikube service task-api-service --url

# Run the demo script (pauses at each step for screenshots)
.\take-screenshots.ps1 -ApiUrl $API_URL
```

Or see detailed manual instructions: [screenshots/TASK2_SCREENSHOT_REQUIREMENTS.md](screenshots/TASK2_SCREENSHOT_REQUIREMENTS.md)

---

## Project Summary

This project demonstrates:

- ✅ RESTful API design with Spring Boot
- ✅ MongoDB integration with Spring Data
- ✅ Command validation and security
- ✅ Dockerization with multi-stage builds
- ✅ Kubernetes deployment and orchestration
- ✅ Dynamic pod creation using Kubernetes API
- ✅ Persistent storage with PersistentVolumes
- ✅ RBAC for secure Kubernetes access
- ✅ Environment-based configuration
- ✅ Production-ready manifests with health checks

---

**For detailed Task 2 documentation, see [TASK2_README.md](TASK2_README.md)**


