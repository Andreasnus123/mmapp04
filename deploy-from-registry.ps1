# Deploy from GitHub Container Registry to Local Kubernetes

# This script pulls images from GHCR and deploys to your local Kubernetes cluster

param(
    [string]$Username = "",
    [string]$Tag = "latest"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploy from GitHub Container Registry" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if username is provided
if ([string]::IsNullOrEmpty($Username)) {
    $Username = Read-Host "Enter your GitHub username"
}

$REGISTRY = "ghcr.io"
$BACKEND_IMAGE = "$REGISTRY/$Username/llm-backend:$Tag"
$FRONTEND_IMAGE = "$REGISTRY/$Username/llm-frontend:$Tag"
$MULTIROUTE_IMAGE = "$REGISTRY/$Username/llm-multiroute:$Tag"

Write-Host "Using images:" -ForegroundColor Yellow
Write-Host "  Backend:    $BACKEND_IMAGE" -ForegroundColor White
Write-Host "  Frontend:   $FRONTEND_IMAGE" -ForegroundColor White
Write-Host "  Multiroute: $MULTIROUTE_IMAGE" -ForegroundColor White
Write-Host ""

# Login to GHCR (optional, only needed for private repos)
Write-Host "Logging in to GitHub Container Registry..." -ForegroundColor Yellow
Write-Host "If your repository is public, you can skip this by pressing Ctrl+C" -ForegroundColor Gray
Write-Host ""

try {
    $token = Read-Host "Enter your GitHub Personal Access Token (or press Enter to skip)" -AsSecureString
    if ($token.Length -gt 0) {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
        $plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        echo $plainToken | docker login $REGISTRY -u $Username --password-stdin
        Write-Host "✓ Logged in successfully" -ForegroundColor Green
    }
    else {
        Write-Host "Skipping login (assuming public repository)" -ForegroundColor Gray
    }
}
catch {
    Write-Host "⚠ Login skipped or failed. Continuing..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pulling images from registry..." -ForegroundColor Yellow

# Pull images
docker pull $BACKEND_IMAGE
docker pull $FRONTEND_IMAGE
docker pull $MULTIROUTE_IMAGE

Write-Host "✓ Images pulled successfully" -ForegroundColor Green
Write-Host ""

# Tag images for local use
Write-Host "Tagging images for local deployment..." -ForegroundColor Yellow
docker tag $BACKEND_IMAGE llm-backend:latest
docker tag $FRONTEND_IMAGE llm-frontend:latest
docker tag $MULTIROUTE_IMAGE llm-multiroute:latest

Write-Host "✓ Images tagged" -ForegroundColor Green
Write-Host ""

# Deploy to Kubernetes
Write-Host "Deploying to Kubernetes..." -ForegroundColor Yellow
kubectl apply -f k8s/

Write-Host ""
Write-Host "Waiting for pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=llm-backend --timeout=60s
kubectl wait --for=condition=ready pod -l app=llm-frontend --timeout=60s
kubectl wait --for=condition=ready pod -l app=llm-multiroute --timeout=60s

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Status" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
kubectl get pods
Write-Host ""
kubectl get services

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access your application at:" -ForegroundColor Yellow
Write-Host "  Frontend:   http://localhost:5000" -ForegroundColor White
Write-Host "  Multiroute: http://localhost:8000 (via port-forward if needed)" -ForegroundColor White
Write-Host ""
