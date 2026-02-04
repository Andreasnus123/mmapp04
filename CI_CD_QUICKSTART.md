# CI/CD Pipeline Quick Start

## Prerequisites

- GitHub repository
- Kubernetes cluster access
- OpenAI API key

---

## Setup Steps

### 1. Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

#### OPENAI_API_KEY
```
Your OpenAI API key (starts with sk-)
```

#### KUBE_CONFIG
```bash
# Get base64-encoded kubeconfig
cat ~/.kube/config | base64 -w 0

# Or on macOS
cat ~/.kube/config | base64

# Add the output as the secret value
```

---

### 2. Push Code to GitHub

```bash
git add .
git commit -m "feat: add CI/CD pipeline"
git push origin main
```

---

### 3. Verify Pipeline

1. Go to **Actions** tab in GitHub
2. You should see workflows running
3. Check that all jobs complete successfully

---

### 4. Test the Pipeline

#### Create a Test PR

```bash
# Create a branch
git checkout -b test/pipeline

# Make a small change
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "test: verify CI/CD pipeline"
git push origin test/pipeline
```

#### Open PR on GitHub
- Go to your repository
- Click "Pull requests" → "New pull request"
- Select your branch
- Create the PR
- Watch the checks run

---

### 5. Deploy to Production

Once your PR is merged to `main`:
1. Build and Deploy workflow triggers automatically
2. Docker images are built and pushed to GHCR
3. Application deploys to Kubernetes
4. Verify deployment:
   ```bash
   kubectl get pods
   kubectl get services
   ```

---

## Workflows Overview

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **PR Checks** | Pull requests | Lint code, validate files |
| **Test Pipeline** | PR & Push | Run promptfoo & deepeval tests |
| **Build & Deploy** | Push to main | Build images, deploy to K8s |

---

## Common Commands

### View Workflow Status
```bash
# Using GitHub CLI
gh workflow list
gh run list
gh run view <run-id>
```

### Manual Trigger
```bash
# Using GitHub CLI
gh workflow run test.yml
gh workflow run build-deploy.yml
```

### Check Deployment
```bash
kubectl get all
kubectl logs -l app=llm-backend
kubectl logs -l app=llm-frontend
kubectl logs -l app=llm-multiroute
```

---

## Troubleshooting

### Tests Fail
- Check `OPENAI_API_KEY` is set
- Review test logs in Actions tab

### Build Fails
- Check Dockerfile syntax
- Verify dependencies are correct

### Deploy Fails
- Verify `KUBE_CONFIG` is correct
- Check cluster connectivity
- Review deployment logs

---

## Next Steps

1. ✅ Add status badges to README
2. ✅ Set up branch protection rules
3. ✅ Configure auto-merge for dependabot
4. ✅ Add more tests
5. ✅ Set up monitoring and alerts

---

For detailed documentation, see [CI_CD_DOCUMENTATION.md](./CI_CD_DOCUMENTATION.md)
