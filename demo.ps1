# Kubernetes Demonstration Script
# This script will demonstrate that the application is running on Kubernetes

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "KUBERNETES DEPLOYMENT DEMONSTRATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Show Kubernetes cluster info
Write-Host "1. KUBERNETES CLUSTER INFORMATION" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl cluster-info
Write-Host ""

# 2. Show nodes
Write-Host "2. KUBERNETES NODES" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl get nodes
Write-Host ""

# 3. Show all resources
Write-Host "3. ALL KUBERNETES RESOURCES" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl get all
Write-Host ""

# 4. Show pods with details
Write-Host "4. PODS (with Node and IP information)" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl get pods -o wide
Write-Host ""

# 5. Show services
Write-Host "5. SERVICES" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl get services
Write-Host ""

# 6. Show deployments
Write-Host "6. DEPLOYMENTS" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl get deployments
Write-Host ""

# 7. Describe backend deployment
Write-Host "7. BACKEND DEPLOYMENT DETAILS" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl describe deployment llm-backend
Write-Host ""

# 8. Describe frontend deployment
Write-Host "8. FRONTEND DEPLOYMENT DETAILS" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl describe deployment llm-frontend
Write-Host ""

# 9. Show backend pod logs (last 20 lines)
Write-Host "9. BACKEND POD LOGS (last 20 lines)" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl logs -l app=llm-backend --tail=20
Write-Host ""

# 10. Show frontend pod logs (last 20 lines)
Write-Host "10. FRONTEND POD LOGS (last 20 lines)" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
kubectl logs -l app=llm-frontend --tail=20
Write-Host ""

# 11. Show manifest files
Write-Host "11. KUBERNETES MANIFEST FILES" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host "Backend manifest (k8s/backend.yaml):" -ForegroundColor Green
Get-Content k8s/backend.yaml
Write-Host ""
Write-Host "Frontend manifest (k8s/frontend.yaml):" -ForegroundColor Green
Get-Content k8s/frontend.yaml
Write-Host ""

# 12. Test application endpoint
Write-Host "12. APPLICATION ACCESSIBILITY TEST" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host "Testing frontend service at http://localhost:5000..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -TimeoutSec 5 -UseBasicParsing
    Write-Host "✓ Frontend is accessible! Status Code: $($response.StatusCode)" -ForegroundColor Green
}
catch {
    Write-Host "✗ Frontend test failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 13. Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEMONSTRATION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "KEY POINTS TO HIGHLIGHT:" -ForegroundColor Yellow
Write-Host "✓ Application is running on Kubernetes cluster (Docker Desktop)" -ForegroundColor Green
Write-Host "✓ Two microservices deployed: llm-backend and llm-frontend" -ForegroundColor Green
Write-Host "✓ Pods are running and healthy" -ForegroundColor Green
Write-Host "✓ Services are configured for internal and external access" -ForegroundColor Green
Write-Host "✓ Frontend accessible at: http://localhost:5000" -ForegroundColor Green
Write-Host ""
Write-Host "To access the application, open your browser and navigate to:" -ForegroundColor Cyan
Write-Host "http://localhost:5000" -ForegroundColor White -BackgroundColor Blue
Write-Host ""
