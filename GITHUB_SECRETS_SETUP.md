# How to Configure KUBE_CONFIG GitHub Secret

## Step-by-Step Guide

### Step 1: Get Your Kubeconfig File

First, you need to encode your kubeconfig file to base64.

#### On Windows (PowerShell):

```powershell
# Navigate to your .kube directory
cd "C:\Users\ERP 2.0\.kube"

# Convert config to base64
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("config")) | Set-Clipboard

# The base64 string is now in your clipboard!
```

**Alternative method (if above doesn't work):**

```powershell
# Read the file and convert to base64
$configContent = Get-Content -Path "C:\Users\ERP 2.0\.kube\config" -Raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($configContent)
$base64 = [Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
Write-Host "Base64 config copied to clipboard!"
```

#### On Linux/Mac:

```bash
cat ~/.kube/config | base64 -w 0 | pbcopy  # macOS
cat ~/.kube/config | base64 -w 0 | xclip   # Linux
```

---

### Step 2: Add Secret to GitHub

1. **Go to your GitHub repository**
   - Navigate to: `https://github.com/<your-username>/<your-repo>`

2. **Open Settings**
   - Click on **Settings** tab (top right)

3. **Navigate to Secrets**
   - In the left sidebar, click **Secrets and variables**
   - Click **Actions**

4. **Add New Secret**
   - Click **New repository secret** button

5. **Configure the Secret**
   - **Name**: `KUBE_CONFIG`
   - **Value**: Paste the base64 string from your clipboard (Ctrl+V)
   - Click **Add secret**

---

### Step 3: Verify the Secret

After adding the secret, you should see:
- ✅ `KUBE_CONFIG` listed under "Repository secrets"
- The value will be hidden (shown as `***`)

---

### Step 4: Add OPENAI_API_KEY (if not done yet)

While you're in the Secrets page:

1. Click **New repository secret**
2. **Name**: `OPENAI_API_KEY`
3. **Value**: Your OpenAI API key (starts with `sk-`)
4. Click **Add secret**

---

## Important Notes

> [!WARNING]
> **Security Considerations**
> - Never commit kubeconfig to your repository
> - The base64 encoding is NOT encryption, it's just formatting
> - GitHub Secrets are encrypted and only accessible to GitHub Actions
> - Rotate your kubeconfig if it's ever exposed

> [!IMPORTANT]
> **Cluster Access**
> - Ensure your Kubernetes cluster is accessible from the internet (for GitHub Actions)
> - For Docker Desktop, you may need to expose the cluster or use a different approach
> - Consider using a cloud Kubernetes cluster (GKE, EKS, AKS) for production CI/CD

---

## Testing the Configuration

After adding the secret, test it by:

1. **Trigger a workflow manually:**
   - Go to **Actions** tab
   - Select "Build and Deploy" workflow
   - Click **Run workflow**
   - Select `main` branch
   - Click **Run workflow**

2. **Check the logs:**
   - Click on the running workflow
   - Click on the "Deploy to Kubernetes" job
   - Look for "Configure kubectl" step
   - Should show: ✅ Successfully configured kubectl

---

## Troubleshooting

### Error: "error: error loading config file"

**Problem:** The base64 string is corrupted or incorrect

**Solution:**
```powershell
# Try this alternative method
$config = Get-Content "C:\Users\ERP 2.0\.kube\config" -Raw
$base64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($config))
Write-Host $base64
# Copy the output and paste into GitHub
```

### Error: "The connection to the server localhost:8080 was refused"

**Problem:** Docker Desktop Kubernetes context points to localhost

**Solution:**
For Docker Desktop, you have two options:

**Option 1: Use a cloud cluster** (Recommended for CI/CD)
- Set up a cluster on GKE, EKS, or AKS
- Get that cluster's kubeconfig
- Use that for `KUBE_CONFIG`

**Option 2: Modify the workflow for local deployment**
- Remove the auto-deploy step
- Build and push images only
- Deploy manually from your local machine

---

## Alternative: Using GitHub Actions Self-Hosted Runner

If you want to deploy to your local Docker Desktop cluster:

1. **Set up a self-hosted runner** on your local machine
2. **Modify the workflow** to use the self-hosted runner:
   ```yaml
   deploy:
     runs-on: self-hosted  # Instead of ubuntu-latest
   ```
3. **No need for KUBE_CONFIG secret** - runner uses local kubectl

---

## Quick Reference

### Required Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `KUBE_CONFIG` | Base64-encoded kubeconfig | `[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\Users\ERP 2.0\.kube\config"))` |
| `OPENAI_API_KEY` | OpenAI API key | Get from https://platform.openai.com/api-keys |

### PowerShell Command (Copy-Paste Ready)

```powershell
# Run this in PowerShell to get your base64 kubeconfig
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Users\ERP 2.0\.kube\config")) | Set-Clipboard
Write-Host "✅ Base64 kubeconfig copied to clipboard!"
Write-Host "Now paste it into GitHub Secrets as KUBE_CONFIG"
```

---

## Next Steps

After configuring the secrets:

1. ✅ Push your code to GitHub
2. ✅ Create a test PR to verify tests run
3. ✅ Merge to main to trigger deployment
4. ✅ Monitor the Actions tab for deployment status

For more information, see [CI_CD_DOCUMENTATION.md](./CI_CD_DOCUMENTATION.md)
