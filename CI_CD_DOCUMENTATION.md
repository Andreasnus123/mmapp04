# CI/CD Pipeline Documentation

## Overview

This project uses **GitHub Actions** for continuous integration and continuous deployment (CI/CD). The pipeline automatically tests, builds, and deploys the application to Kubernetes.

---

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
└─────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
        ┌───────▼────────┐     ┌───────▼────────┐
        │  Pull Request  │     │  Push to main  │
        └───────┬────────┘     └───────┬────────┘
                │                       │
        ┌───────▼────────┐     ┌───────▼────────┐
        │   PR Checks    │     │  Test Pipeline │
        │  - Lint Code   │     │  - Promptfoo   │
        │  - Validate    │     │  - Deepeval    │
        └────────────────┘     └───────┬────────┘
                                       │
                               ┌───────▼────────┐
                               │ Build & Deploy │
                               │  - Build Images│
                               │  - Push to GHCR│
                               │  - Deploy K8s  │
                               └───────┬────────┘
                                       │
                               ┌───────▼────────┐
                               │   Kubernetes   │
                               │    Cluster     │
                               └────────────────┘
```

---

## Workflows

### 1. **PR Checks** (`.github/workflows/pr-checks.yml`)

**Triggers:** Pull requests to `main` or `develop`

**Purpose:** Quick validation checks before merging

**Jobs:**
- **Lint Python Code**: Checks code formatting with `black`, `isort`, and `flake8`
- **Validate Dockerfiles**: Lints Dockerfiles with `hadolint`
- **Validate Kubernetes Manifests**: Validates K8s YAML files with `kubeval`
- **Check Dependencies**: Scans for security vulnerabilities with `safety`

---

### 2. **Test Pipeline** (`.github/workflows/test.yml`)

**Triggers:** 
- Pull requests to `main` or `develop`
- Pushes to `main` or `develop`
- Manual workflow dispatch

**Purpose:** Run comprehensive tests against the backend API

**Jobs:**

#### Promptfoo Tests
- Builds the Java backend
- Starts backend service on port 8080
- Runs promptfoo evaluations for all endpoints:
  - Classify
  - Sentiment
  - Summarize
  - Intent
- Uploads test results as artifacts

#### Deepeval Tests
- Builds the Java backend
- Starts backend service
- Runs pytest with deepeval for:
  - Classification tests
  - Sentiment analysis tests
  - Summarization tests
  - Intent detection tests
- Uploads test results as artifacts

---

### 3. **Build and Deploy** (`.github/workflows/build-deploy.yml`)

**Triggers:**
- Pushes to `main` branch
- Git tags matching `v*.*.*`
- Manual workflow dispatch

**Purpose:** Build Docker images and deploy to Kubernetes

**Jobs:**

#### Build Backend (llm)
- Builds Java Spring Boot application with Maven
- Creates Docker image
- Pushes to GitHub Container Registry (ghcr.io)
- Tags: `latest`, `main-<sha>`, version tags

#### Build Frontend (llm-frontend-python)
- Creates Docker image for Flask frontend
- Pushes to GHCR
- Tags: `latest`, `main-<sha>`, version tags

#### Build Multiroute (llm-multiroute)
- Creates Docker image for FastAPI multiroute service
- Pushes to GHCR
- Tags: `latest`, `main-<sha>`, version tags

#### Deploy to Kubernetes
- Updates image tags in K8s manifests
- Applies manifests to cluster
- Waits for rollout completion
- Verifies deployment health

---

## GitHub Secrets Configuration

Configure these secrets in **Settings → Secrets and variables → Actions**:

| Secret Name | Description | Required | Example |
|-------------|-------------|----------|---------|
| `GITHUB_TOKEN` | Auto-provided by GitHub | ✅ Yes | (automatic) |
| `OPENAI_API_KEY` | OpenAI API key for tests | ✅ Yes | `sk-proj-...` |
| `KUBE_CONFIG` | Base64-encoded kubeconfig | ✅ Yes | See below |

### Setting up KUBE_CONFIG

1. **Get your kubeconfig:**
   ```bash
   cat ~/.kube/config | base64 -w 0
   ```

2. **Add to GitHub Secrets:**
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `KUBE_CONFIG`
   - Value: Paste the base64-encoded config
   - Click "Add secret"

### Setting up OPENAI_API_KEY

1. Get your API key from https://platform.openai.com/api-keys
2. Add to GitHub Secrets:
   - Name: `OPENAI_API_KEY`
   - Value: Your API key (starts with `sk-`)

---

## Container Images

All images are pushed to **GitHub Container Registry (ghcr.io)**:

- `ghcr.io/<your-username>/llm-backend:latest`
- `ghcr.io/<your-username>/llm-frontend:latest`
- `ghcr.io/<your-username>/llm-multiroute:latest`

### Image Tags

- `latest` - Latest build from main branch
- `main-<sha>` - Specific commit from main
- `v1.0.0` - Semantic version tags
- `v1.0` - Major.minor version

### Pulling Images Locally

```bash
# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u <username> --password-stdin

# Pull images
docker pull ghcr.io/<username>/llm-backend:latest
docker pull ghcr.io/<username>/llm-frontend:latest
docker pull ghcr.io/<username>/llm-multiroute:latest
```

---

## Manual Workflow Triggers

You can manually trigger workflows from the GitHub Actions tab:

1. Go to **Actions** tab in your repository
2. Select the workflow (Test Pipeline or Build and Deploy)
3. Click **Run workflow**
4. Select branch
5. Click **Run workflow** button

---

## Monitoring Pipeline Status

### View Workflow Runs

1. Go to **Actions** tab
2. Click on a workflow run to see details
3. Click on individual jobs to see logs

### Status Badges

Add these to your README.md:

```markdown
![Test Pipeline](https://github.com/<username>/<repo>/actions/workflows/test.yml/badge.svg)
![Build and Deploy](https://github.com/<username>/<repo>/actions/workflows/build-deploy.yml/badge.svg)
![PR Checks](https://github.com/<username>/<repo>/actions/workflows/pr-checks.yml/badge.svg)
```

---

## Local Development Workflow

### Before Creating a PR

1. **Lint your code:**
   ```bash
   # Python
   cd llm-frontend-python
   black .
   isort .
   flake8 . --max-line-length=120
   
   cd ../llm-multiroute
   black .
   isort .
   flake8 . --max-line-length=120
   ```

2. **Test locally:**
   ```bash
   # Start backend
   cd llm
   mvn spring-boot:run
   
   # In another terminal, run tests
   cd promptfoo-tests
   npm run eval
   
   cd ../deepeval-tests
   pytest -v
   ```

3. **Validate Kubernetes manifests:**
   ```bash
   kubectl apply --dry-run=client -f k8s/
   ```

### Creating a Pull Request

1. Create a feature branch:
   ```bash
   git checkout -b feature/my-feature
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Push to GitHub:
   ```bash
   git push origin feature/my-feature
   ```

4. Open a Pull Request on GitHub
5. Wait for PR checks to pass
6. Request review
7. Merge when approved

### Deploying to Production

1. **Merge to main:**
   - Merge your PR to `main` branch
   - This triggers the build and deploy workflow

2. **Tag a release (optional):**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **Monitor deployment:**
   - Check GitHub Actions for deployment status
   - Verify pods are running:
     ```bash
     kubectl get pods
     kubectl get services
     ```

---

## Troubleshooting

### Tests Failing

**Problem:** Promptfoo or Deepeval tests fail

**Solutions:**
1. Check if `OPENAI_API_KEY` secret is set correctly
2. Verify backend service started successfully in logs
3. Check test assertions in test files
4. Run tests locally to reproduce

### Build Failing

**Problem:** Docker build fails

**Solutions:**
1. Check Dockerfile syntax
2. Verify all dependencies are in requirements.txt or pom.xml
3. Check build logs for specific errors
4. Test build locally:
   ```bash
   docker build -t test-image ./llm
   ```

### Deployment Failing

**Problem:** Kubernetes deployment fails

**Solutions:**
1. Verify `KUBE_CONFIG` secret is set correctly
2. Check if cluster is accessible
3. Verify image names and tags in manifests
4. Check deployment logs:
   ```bash
   kubectl describe deployment llm-backend
   kubectl logs -l app=llm-backend
   ```

### Image Push Failing

**Problem:** Cannot push to GHCR

**Solutions:**
1. Verify `GITHUB_TOKEN` has package write permissions
2. Check if repository is public (GHCR requires public repos or proper permissions)
3. Enable package permissions in repository settings

---

## Pipeline Optimization

### Caching

The pipeline uses caching to speed up builds:

- **Maven dependencies**: Cached between runs
- **Python pip packages**: Cached between runs
- **Docker layers**: Cached in registry

### Parallel Execution

Jobs run in parallel when possible:
- All build jobs run simultaneously
- Test jobs run in parallel
- PR checks run in parallel

### Conditional Execution

- Deployment only runs on `main` branch
- PR checks only run on pull requests
- Tests run on both PRs and pushes

---

## Best Practices

1. **Always create PRs**: Don't push directly to `main`
2. **Wait for tests**: Don't merge until all checks pass
3. **Use semantic versioning**: Tag releases with `v1.0.0` format
4. **Monitor deployments**: Check logs after deployment
5. **Keep secrets secure**: Never commit secrets to code
6. **Update dependencies**: Regularly update requirements.txt and pom.xml
7. **Write good commit messages**: Use conventional commits format

---

## Services Included

✅ **Backend (llm)**: Java Spring Boot API  
✅ **Frontend (llm-frontend-python)**: Flask web application  
✅ **Multiroute (llm-multiroute)**: FastAPI routing service  
✅ **Promptfoo Tests**: API evaluation framework  
✅ **Deepeval Tests**: LLM evaluation with pytest  

---

## Next Steps

1. ✅ Configure GitHub Secrets
2. ✅ Push code to GitHub
3. ✅ Create a test PR to verify pipeline
4. ✅ Merge to main to trigger deployment
5. ✅ Monitor application in Kubernetes

**Your CI/CD pipeline is ready!** 🚀
