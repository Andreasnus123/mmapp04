# CI/CD Workflow for Docker Desktop Kubernetes

This document explains the modified CI/CD workflow for use with Docker Desktop Kubernetes.

---

## Workflow Overview

Since Docker Desktop Kubernetes runs on `localhost`, GitHub Actions cannot directly deploy to it. Instead, the workflow:

1. ✅ **Runs Tests** - Promptfoo and Deepeval tests on every PR
2. ✅ **Builds Images** - Builds Docker images for all services
3. ✅ **Pushes to Registry** - Pushes images to GitHub Container Registry (GHCR)
4. ⚠️ **Manual Deployment** - You deploy manually from your local machine

---

## How It Works

### On Pull Request
```
PR Created → PR Checks Run → Tests Run → Review & Merge
```

### On Push to Main
```
Push to Main → Build Images → Push to GHCR → Ready for Deployment
```

### Manual Deployment
```
Pull Images from GHCR → Deploy to Local K8s → Application Running
```

---

## Required GitHub Secrets

You only need **ONE** secret now:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `OPENAI_API_KEY` | OpenAI API key for tests | Get from https://platform.openai.com/api-keys |

**No need for `KUBE_CONFIG`** since deployment is manual!

---

## Deployment Process

### Option 1: Deploy from Registry (Recommended)

After GitHub Actions builds and pushes images:

```powershell
# Pull images from GHCR and deploy
./deploy-from-registry.ps1 -Username <your-github-username>
```

This script will:
1. Pull latest images from GHCR
2. Tag them for local use
3. Deploy to your local Kubernetes cluster

### Option 2: Build and Deploy Locally

Build images locally and deploy:

```powershell
# Build and deploy from source
./deploy.ps1
```

---

## Workflow Files

### [.github/workflows/test.yml](file:///c:/Users/ERP%202.0/llmapp/llmapp04/.github/workflows/test.yml)
- Runs on: Pull requests and pushes
- Purpose: Run promptfoo and deepeval tests

### [.github/workflows/build-deploy.yml](file:///c:/Users/ERP%202.0/llmapp/llmapp04/.github/workflows/build-deploy.yml)
- Runs on: Push to main
- Purpose: Build and push Docker images to GHCR
- **Note**: Does NOT auto-deploy (manual deployment required)

### [.github/workflows/pr-checks.yml](file:///c:/Users/ERP%202.0/llmapp/llmapp04/.github/workflows/pr-checks.yml)
- Runs on: Pull requests
- Purpose: Lint code and validate files

---

## Typical Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/my-feature
```

### 2. Make Changes and Test Locally
```bash
# Test locally
cd promptfoo-tests
npm run eval

cd ../deepeval-tests
pytest -v
```

### 3. Push and Create PR
```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/my-feature
```

### 4. Wait for CI Checks
- PR checks run (linting, validation)
- Tests run (promptfoo, deepeval)
- Review results in GitHub Actions tab

### 5. Merge to Main
- Once approved, merge PR
- GitHub Actions builds images
- Images pushed to GHCR

### 6. Deploy Locally
```powershell
# Pull and deploy latest images
./deploy-from-registry.ps1 -Username <your-username>
```

---

## Image Locations

After successful build, images are available at:

```
ghcr.io/<your-username>/llm-backend:latest
ghcr.io/<your-username>/llm-frontend:latest
ghcr.io/<your-username>/llm-multiroute:latest
```

You can also use specific tags:
- `main-<commit-sha>` - Specific commit
- `v1.0.0` - Version tags

---

## Advantages of This Approach

✅ **No KUBE_CONFIG needed** - Simpler setup  
✅ **Works with Docker Desktop** - No cloud cluster required  
✅ **Full CI/CD testing** - Tests run automatically  
✅ **Automated builds** - Images built on every merge  
✅ **Manual control** - You decide when to deploy  
✅ **Easy rollback** - Deploy any previous image version  

---

## Upgrading to Auto-Deployment (Future)

When you're ready to use a cloud Kubernetes cluster:

1. Set up cluster (GKE, EKS, or AKS)
2. Add `KUBE_CONFIG` secret with cloud cluster config
3. Uncomment the `deploy` job in `build-deploy.yml`
4. Push to main → Auto-deployment to cloud!

---

## Troubleshooting

### Images not appearing in GHCR

**Problem:** Can't find images in GitHub Container Registry

**Solution:**
1. Check workflow logs in Actions tab
2. Verify `GITHUB_TOKEN` has package write permissions
3. Make repository public or configure package permissions

### Cannot pull images locally

**Problem:** `docker pull` fails with authentication error

**Solution:**
```powershell
# Create a Personal Access Token with read:packages scope
# Then login:
echo <your-token> | docker login ghcr.io -u <username> --password-stdin
```

### Deployment fails

**Problem:** `kubectl apply` fails

**Solution:**
1. Verify Kubernetes is running: `kubectl get nodes`
2. Check image names in manifests match GHCR images
3. Ensure images are pulled: `docker images | grep llm`

---

## Next Steps

1. ✅ Add `OPENAI_API_KEY` to GitHub Secrets
2. ✅ Push code to GitHub
3. ✅ Create a test PR to verify tests run
4. ✅ Merge to main to build images
5. ✅ Deploy locally with `deploy-from-registry.ps1`

For detailed setup, see [CI_CD_QUICKSTART.md](./CI_CD_QUICKSTART.md)
