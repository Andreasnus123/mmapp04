# Kubernetes Deployment Demonstration

**Student Name:** [Your Name]  
**Date:** February 4, 2026  
**Project:** LLM Application on Kubernetes

---

## Executive Summary

This document demonstrates that the LLM application is successfully deployed and running on a Kubernetes cluster (Docker Desktop Kubernetes). The application consists of two microservices:
- **Backend Service** (Java Spring Boot)
- **Frontend Service** (Python Flask)

---

## 1. Cluster Information

### Verify Kubernetes Cluster is Running

**Command:**
```powershell
kubectl cluster-info
```

**Output:**
```
Kubernetes control plane is running at https://kubernetes.docker.internal:6443
CoreDNS is running at https://kubernetes.docker.internal:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

**Command:**
```powershell
kubectl get nodes
```

**Output:**
```
NAME             STATUS   ROLES           AGE     VERSION
docker-desktop   Ready    control-plane   12m     v1.34.1
```

✅ **Proof:** The cluster is running on Docker Desktop Kubernetes v1.34.1

---

## 2. Deployed Resources

### View All Kubernetes Resources

**Command:**
```powershell
kubectl get all
```

**Output:**
```
NAME                                READY   STATUS    RESTARTS   AGE
pod/llm-backend-78588f655d-xkwjp    1/1     Running   0          9m43s
pod/llm-frontend-85b546f956-s6nnq   1/1     Running   0          9m43s

NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/kubernetes     ClusterIP      10.96.0.1        <none>        443/TCP          12m
service/llm-backend    ClusterIP      10.110.169.129   <none>        8080/TCP         9m43s
service/llm-frontend   LoadBalancer   10.111.12.39     localhost     5000:30992/TCP   9m43s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/llm-backend    1/1     1            1           9m43s
deployment.apps/llm-frontend   1/1     1            1           9m43s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/llm-backend-78588f655d    1         1         1       9m43s
replicaset.apps/llm-frontend-85b546f956   1         1         1       9m43s
```

✅ **Proof:** 
- 2 Deployments are running
- 2 Pods are in "Running" status
- 2 Services are exposed (ClusterIP for backend, LoadBalancer for frontend)
- ReplicaSets are managing the pods

---

## 3. Pod Details

### View Pods with Node Information

**Command:**
```powershell
kubectl get pods -o wide
```

**Output:**
```
NAME                            READY   STATUS    RESTARTS   AGE      IP         NODE             
llm-backend-78588f655d-xkwjp    1/1     Running   0          9m43s    10.1.0.6   docker-desktop
llm-frontend-85b546f956-s6nnq   1/1     Running   0          9m43s    10.1.0.7   docker-desktop
```

✅ **Proof:** Both pods are running on the Kubernetes node with internal cluster IPs

---

## 4. Deployment Configuration

### Backend Deployment Details

**Command:**
```powershell
kubectl describe deployment llm-backend
```

**Key Information:**
- **Name:** llm-backend
- **Namespace:** default
- **Replicas:** 1 desired | 1 updated | 1 total | 1 available
- **Pod Template:**
  - **Image:** llm-backend:latest
  - **Port:** 8080/TCP
  - **Image Pull Policy:** IfNotPresent

### Frontend Deployment Details

**Command:**
```powershell
kubectl describe deployment llm-frontend
```

**Key Information:**
- **Name:** llm-frontend
- **Namespace:** default
- **Replicas:** 1 desired | 1 updated | 1 total | 1 available
- **Pod Template:**
  - **Image:** llm-frontend:latest
  - **Port:** 5000/TCP
  - **Environment Variables:**
    - `BACKEND_URL=http://llm-backend:8080`
    - `FLASK_PORT=5000`
  - **Image Pull Policy:** IfNotPresent

✅ **Proof:** Deployments are configured with custom Docker images and proper service discovery

---

## 5. Service Configuration

### View Services

**Command:**
```powershell
kubectl get services
```

**Output:**
```
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes     ClusterIP      10.96.0.1        <none>        443/TCP          12m
llm-backend    ClusterIP      10.110.169.129   <none>        8080/TCP         9m43s
llm-frontend   LoadBalancer   10.111.12.39     localhost     5000:30992/TCP   9m43s
```

✅ **Proof:**
- **Backend Service:** Internal ClusterIP (accessible only within cluster)
- **Frontend Service:** LoadBalancer type (accessible externally at localhost:5000)
- Services enable pod-to-pod communication via DNS

---

## 6. Kubernetes Manifest Files

### Backend Manifest ([k8s/backend.yaml](file:///c:/Users/ERP%202.0/llmapp/llmapp04/k8s/backend.yaml))

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llm-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: llm-backend
  template:
    metadata:
      labels:
        app: llm-backend
    spec:
      containers:
        - name: llm-backend
          image: llm-backend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: llm-backend
spec:
  selector:
    app: llm-backend
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
```

### Frontend Manifest ([k8s/frontend.yaml](file:///c:/Users/ERP%202.0/llmapp/llmapp04/k8s/frontend.yaml))

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llm-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: llm-frontend
  template:
    metadata:
      labels:
        app: llm-frontend
    spec:
      containers:
        - name: llm-frontend
          image: llm-frontend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 5000
          env:
            - name: BACKEND_URL
              value: "http://llm-backend:8080"
            - name: FLASK_PORT
              value: "5000"
---
apiVersion: v1
kind: Service
metadata:
  name: llm-frontend
spec:
  type: LoadBalancer
  selector:
    app: llm-frontend
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
```

---

## 7. Application Access

### Frontend URL
**Access the application at:** http://localhost:5000

The frontend service is exposed via LoadBalancer and accessible from the host machine.

### Service Communication
The frontend communicates with the backend using Kubernetes DNS:
- Frontend → `http://llm-backend:8080` (internal cluster DNS)
- This demonstrates **service discovery** in Kubernetes

---

## 8. Verification Commands for Professor

To verify the deployment yourself, run these commands:

```powershell
# 1. Check cluster status
kubectl cluster-info

# 2. View all resources
kubectl get all

# 3. Check pod status
kubectl get pods -o wide

# 4. View services
kubectl get services

# 5. Describe deployments
kubectl describe deployment llm-backend
kubectl describe deployment llm-frontend

# 6. View pod logs (backend)
kubectl logs -l app=llm-backend

# 7. View pod logs (frontend)
kubectl logs -l app=llm-frontend

# 8. Access the application
# Open browser: http://localhost:5000
```

---

## 9. Key Kubernetes Features Demonstrated

✅ **Deployments:** Declarative application deployment  
✅ **ReplicaSets:** Ensures desired number of pod replicas  
✅ **Services:** Load balancing and service discovery  
✅ **Pods:** Containerized application instances  
✅ **Service Types:** ClusterIP (internal) and LoadBalancer (external)  
✅ **Environment Variables:** Configuration management  
✅ **DNS-based Service Discovery:** Inter-service communication  
✅ **Container Orchestration:** Automated deployment and scaling  

---

## 10. Deployment Script

The deployment is automated using [deploy.ps1](file:///c:/Users/ERP%202.0/llmapp/llmapp04/deploy.ps1):

```powershell
# Build Docker images
docker build -t llm-backend:latest ./llm
docker build -t llm-frontend:latest ./llm-frontend-python

# Apply Kubernetes manifests
kubectl apply -f k8s/

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=llm-backend --timeout=60s
kubectl wait --for=condition=ready pod -l app=llm-frontend --timeout=60s

# Display service information
kubectl get services
```

---

## Conclusion

This demonstration proves that:
1. ✅ The application is deployed on a **Kubernetes cluster** (Docker Desktop)
2. ✅ Both microservices are running as **Kubernetes Pods**
3. ✅ Services are properly configured for **internal and external access**
4. ✅ The deployment uses **Kubernetes-native features** (Deployments, Services, ReplicaSets)
5. ✅ The application is accessible at **http://localhost:5000**

**The application is fully containerized and orchestrated by Kubernetes.**
