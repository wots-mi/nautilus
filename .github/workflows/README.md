# GitHub Actions Workflows

This repository uses GitHub Actions for automated Terraform deployments across three infrastructure layers.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 0: Bootstrap (alz-level-0)                           │
│  - User Assigned Managed Identity                           │
│  - Storage Account for Terraform State                      │
│  - Federated Identity Credentials (OIDC)                    │
│  - GitHub Environment & Secrets                             │
│  Deployment: Manual (workflow_dispatch)                     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Governance (alz-layer-1)                          │
│  - Management Infrastructure (Log Analytics, Automation)    │
│  - Azure Policy Definitions (158+)                          │
│  - Policy Assignments                                       │
│  Deployment: Auto on main push (dev only)                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Workloads (terraform/)                            │
│  - Application Resources                                    │
│  - Compliant with assigned policies                         │
│  Deployment: Auto on main push (dev only)                   │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Workflow Inventory

### Bootstrap Workflows (alz-level-0)

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `bootstrap-plan.yml` | PR to main | Preview bootstrap infrastructure changes |
| `bootstrap-apply.yml` | Manual | Deploy bootstrap infrastructure (requires "bootstrap" confirmation) |
| `bootstrap-destroy.yml` | Manual | Destroy bootstrap infrastructure (requires "destroy-bootstrap" confirmation) |

**Special Notes:**
- Bootstrap workflows use **local state** by default (backend commented out in `terraform.tf`)
- After first deployment, you can optionally migrate to remote state
- Requires `GH_TOKEN` secret for GitHub provider operations
- Creates the foundation for all other workflows

### Governance Workflows (alz-layer-1)

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `governance-plan.yml` | PR to main with `alz-layer-1/**` changes | Preview governance changes |
| `governance-apply.yml` | Push to main with `alz-layer-1/**` changes | Auto-deploy to dev environment |

**Special Notes:**
- Deploys management infrastructure + policies in single deployment
- Uses OIDC authentication via UAMI created by bootstrap
- No remote state backend (policies don't require state sharing)

### Workload Workflows (terraform/)

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `terraform-plan.yml` | PR to main with `terraform/**` changes | Preview workload changes (dev) |
| `terraform-apply.yml` | Push to main with `terraform/**` changes | Auto-deploy to dev environment |
| `terraform-deploy.yml` | Manual | Deploy to staging/prod with approvals |
| `terraform-destroy.yml` | Manual | Destroy infrastructure (requires confirmation) |

**Special Notes:**
- Uses remote state in Azure Storage (created by bootstrap)
- Supports multi-environment deployments
- Environment protection rules enforce approvals for staging/prod

## 🚀 Deployment Flow

### Initial Setup (First Time)

1. **Deploy Bootstrap Infrastructure**
   ```bash
   # GitHub Actions: Run workflow
   Actions → Bootstrap Apply (alz-level-0) → Run workflow
   Environment: dev
   Confirmation: bootstrap
   ```
   
   Creates:
   - UAMI: `uami-nautilus-dev`
   - Storage Account: `nautilustfstatedev`
   - GitHub Environment: `dev` (with ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID secrets)
   - Federated Credential for OIDC

2. **Verify Bootstrap**
   - Check GitHub Settings → Environments → dev
   - Confirm secrets are created
   - Verify Azure resources in portal

3. **(Optional) Migrate Bootstrap to Remote State**
   ```bash
   cd alz-level-0
   # Uncomment backend block in terraform.tf
   terraform init -migrate-state
   ```

### Normal Development Flow

1. **Make Changes**
   - Create feature branch
   - Edit files in `alz-level-0/`, `alz-layer-1/`, or `terraform/`
   - Commit and push

2. **Create PR**
   - Open PR to `main` branch
   - Appropriate plan workflow runs automatically:
     - Changes in `alz-level-0/**` → `bootstrap-plan.yml`
     - Changes in `alz-layer-1/**` → `governance-plan.yml`
     - Changes in `terraform/**` → `terraform-plan.yml`
   - Review plan output in PR comments

3. **Merge PR**
   - Merge to `main`
   - Appropriate apply workflow runs automatically:
     - `alz-layer-1/**` → `governance-apply.yml` (dev)
     - `terraform/**` → `terraform-apply.yml` (dev)
   - Bootstrap changes require manual workflow trigger

4. **Deploy to Staging/Prod** (Workloads only)
   ```bash
   Actions → Terraform Deploy → Run workflow
   Environment: staging (requires 1 approval)
   Environment: prod (requires 2 approvals)
   ```

## 🔐 Required Secrets

### Repository Secrets

| Secret | Description | Used By |
|--------|-------------|---------|
| `GH_TOKEN` | GitHub Personal Access Token with `repo` scope | Bootstrap workflows (GitHub provider) |

### Environment Secrets (Created by Bootstrap)

| Secret | Description | Created By |
|--------|-------------|------------|
| `ARM_CLIENT_ID` | UAMI Client ID | bootstrap-apply.yml |
| `ARM_TENANT_ID` | Azure Tenant ID | bootstrap-apply.yml |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID | bootstrap-apply.yml |

**Optional Bootstrap Secrets** (for running bootstrap with OIDC):
- `BOOTSTRAP_ARM_CLIENT_ID` - Use existing UAMI for bootstrap deployment
- `BOOTSTRAP_ARM_TENANT_ID` - Tenant ID
- `BOOTSTRAP_ARM_SUBSCRIPTION_ID` - Subscription ID

## 🛡️ Environment Protection Rules

Configure in: **Settings → Environments → [environment]**

### Dev Environment
- ✅ No approval required
- ✅ Auto-deploy on main push
- ⚡ Fast iteration

### Staging Environment
- 🔒 Requires 1 reviewer approval
- 📋 Manual deployment trigger
- ⏱️ Optional wait timer: 5 minutes

### Prod Environment
- 🔒 Requires 2 reviewer approvals
- 📋 Manual deployment trigger
- ⏱️ Optional wait timer: 10 minutes
- 🎯 Protected deployment branch: main only

## 🔄 Concurrency Control

All workflows use concurrency groups to prevent:
- State lock conflicts
- Race conditions
- Simultaneous deployments

```yaml
concurrency:
  group: workflow-name-environment
  cancel-in-progress: false  # Waits for running jobs
```

## 📊 Workflow Features

### Plan Workflows
- ✅ Terraform format check
- ✅ Terraform validation
- ✅ Plan generation
- 💬 PR comment with plan output
- 📦 Plan artifact upload (65KB max in comments)

### Apply Workflows
- ✅ OIDC authentication (no stored credentials)
- ✅ Plan before apply
- ✅ Auto-approve with confirmation
- 📝 Deployment summary
- 🔔 Status notifications

### Destroy Workflows
- 🔴 Requires typed confirmation
- 🔴 Environment-specific approvals
- 🔴 Clear warning messages
- 🔴 Plan -destroy preview

## 🧪 Testing Workflows

### Test PR Workflow
```bash
# Create test branch
git checkout -b test-workflow

# Make small change
echo "# Test" >> terraform/test.tf

# Commit and push
git add terraform/test.tf
git commit -m "test: workflow trigger"
git push origin test-workflow

# Create PR and check workflow runs
```

### Test Bootstrap Workflow
```bash
# GitHub Actions UI
Actions → Bootstrap Apply → Run workflow
Environment: dev
Confirmation: bootstrap

# Watch workflow execution
# Verify resources created in Azure
```

## 📚 Additional Resources

- [Deployment Guide](../DEPLOYMENT_GUIDE.md)
- [OIDC Setup](../OIDC_SETUP.md)
- [Storage Setup](../STORAGE_SETUP.md)
- [alz-level-0 README](../alz-level-0/README.md)
- [alz-layer-1 README](../alz-layer-1/README.md)

## 🐛 Troubleshooting

### "Error: OIDC authentication failed"
- Verify GitHub Environment secrets exist (ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID)
- Check federated credential subject matches: `repo:wots-mi/nautilus:environment:dev`
- Ensure workflow has `environment: dev` configured

### "Error: Terraform state lock"
- Wait for concurrent workflow to finish
- Check concurrency group configuration
- If stuck, manually release lock in Azure Storage

### "Error: Backend initialization failed"
- Verify storage account and container exist (created by bootstrap)
- Check UAMI has "Storage Blob Data Contributor" role
- Confirm backend config in tfvars matches storage account name

### "Error: GitHub provider authentication failed"
- Verify `GH_TOKEN` secret exists in repository
- Check token has `repo` scope
- Ensure token is not expired

## 🎯 Best Practices

1. **Always run bootstrap first** before other layers
2. **Test in dev** before deploying to staging/prod
3. **Review plan output** in PR comments before merging
4. **Use typed confirmations** for destructive operations
5. **Monitor workflow runs** in Actions tab
6. **Keep GH_TOKEN updated** and secure
7. **Document infrastructure changes** in PR descriptions
8. **Use feature branches** for experimental changes
