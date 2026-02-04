# Deploy to Kubernetes

Write-Host "Building Docker images..."
docker build -t llm-backend:latest ./llm
docker build -t llm-frontend:latest ./llm-frontend-python
docker build -t llm-multiroute:latest ./llm-multiroute

Write-Host "Applying Kubernetes manifests..."
kubectl apply -f k8s/

Write-Host "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=llm-backend --timeout=60s
kubectl wait --for=condition=ready pod -l app=llm-frontend --timeout=60s
kubectl wait --for=condition=ready pod -l app=llm-multiroute --timeout=60s

Write-Host "Getting service URLs..."
kubectl get services

Write-Host "Deployment complete!"
Write-Host "Frontend: http://localhost:5000"
Write-Host "Multiroute: http://localhost:8000 (via port-forward if needed)"
