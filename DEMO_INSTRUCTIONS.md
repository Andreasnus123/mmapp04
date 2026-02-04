# Quick Verification Commands for Professor

## To demonstrate the application is running on Kubernetes, run these commands:

### 1. Verify Kubernetes Cluster
```powershell
kubectl cluster-info
kubectl get nodes
```
**Expected:** Shows Docker Desktop Kubernetes cluster is running

---

### 2. Show All Kubernetes Resources
```powershell
kubectl get all
```
**Expected:** Shows deployments, pods, services, and replicasets for both frontend and backend

---

### 3. Show Running Pods
```powershell
kubectl get pods -o wide
```
**Expected:** Shows 2 pods in "Running" status with cluster IPs

---

### 4. Show Services
```powershell
kubectl get services
```
**Expected:** Shows:
- `llm-backend` (ClusterIP) on port 8080
- `llm-frontend` (LoadBalancer) on port 5000 with external IP "localhost"

---

### 5. View Deployment Details
```powershell
kubectl describe deployment llm-backend
kubectl describe deployment llm-frontend
```
**Expected:** Shows deployment configuration including:
- Container images (llm-backend:latest, llm-frontend:latest)
- Ports (8080, 5000)
- Environment variables for frontend

---

### 6. View Pod Logs
```powershell
kubectl logs -l app=llm-backend --tail=20
kubectl logs -l app=llm-frontend --tail=20
```
**Expected:** Shows application logs from both services

---

### 7. Access the Application
Open browser and navigate to: **http://localhost:5000**

**Expected:** The frontend application loads successfully

---

### 8. View Kubernetes Manifests
```powershell
cat k8s/backend.yaml
cat k8s/frontend.yaml
```
**Expected:** Shows the Kubernetes deployment and service configurations

---

## Automated Demo Script

For a comprehensive demonstration, simply run:
```powershell
.\demo.ps1
```

This will execute all verification commands and display the results in an organized format.

---

## Key Kubernetes Features Demonstrated

✅ **Deployments** - Declarative application deployment  
✅ **Pods** - Containerized application instances  
✅ **Services** - Load balancing and service discovery  
✅ **ReplicaSets** - Ensures desired number of replicas  
✅ **Service Types** - ClusterIP (internal) and LoadBalancer (external)  
✅ **DNS-based Service Discovery** - Frontend connects to backend via `http://llm-backend:8080`  
✅ **Environment Variables** - Configuration management  

---

## Evidence Files

1. **KUBERNETES_DEMO.md** - Comprehensive demonstration document with all outputs
2. **demo.ps1** - Automated demonstration script
3. **k8s/backend.yaml** - Backend Kubernetes manifest
4. **k8s/frontend.yaml** - Frontend Kubernetes manifest
5. **deploy.ps1** - Deployment automation script
