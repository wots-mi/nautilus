# Setting up OIDC Authentication for GitHub Actions

This guide walks you through setting up OpenID Connect (OIDC) authentication between GitHub Actions and Azure, which is more secure than using client secrets.

## Prerequisites

- Azure CLI installed and authenticated
- Owner or User Access Administrator role on the Azure subscription
- Repository admin access to configure GitHub secrets

## Step 1: Create Azure AD Application

```bash
# Create the Azure AD app registration
az ad app create --display-name "GitHub-Nautilus-OIDC"
```

Save the `appId` from the output - this is your **AZURE_CLIENT_ID**.

## Step 2: Create Service Principal

```bash
# Replace <APP_ID> with the appId from step 1
APP_ID="<your-app-id>"

az ad sp create --id $APP_ID
```

## Step 3: Assign Permissions

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Assign Contributor role to the service principal
az role assignment create \
  --role Contributor \
  --assignee $APP_ID \
  --scope /subscriptions/$SUBSCRIPTION_ID
```

## Step 4: Configure Federated Credentials

You need to create federated credentials for each workflow trigger (PR, main branch, etc.).

```bash
# Get your tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)

# Create federated credential for main branch (for apply/destroy workflows)
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "GitHub-Nautilus-Main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:wots-mi/nautilus:ref:refs/heads/main",
    "description": "GitHub Actions for main branch",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credential for pull requests (for plan workflow)
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "GitHub-Nautilus-PR",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:wots-mi/nautilus:pull_request",
    "description": "GitHub Actions for pull requests",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Step 5: Configure GitHub Secrets

Go to your GitHub repository settings → Secrets and variables → Actions, and add these secrets:

- `ARM_CLIENT_ID`: The appId from step 1
- `ARM_TENANT_ID`: Your Azure tenant ID (from step 4)
- `ARM_SUBSCRIPTION_ID`: Your Azure subscription ID

## Step 6: Remove Old Secrets (Optional)

Once OIDC is working, you can remove these old secrets:
- `AZURE_CREDENTIALS`
- `ARM_CLIENT_SECRET` (no longer needed with OIDC)

The following secrets are still used:
- `ARM_CLIENT_ID` - Required for OIDC
- `ARM_TENANT_ID` - Required for OIDC
- `ARM_SUBSCRIPTION_ID` - Required for OIDC and TF_VAR_subscription_id_nautilus

## Verification

1. Create a test PR to trigger the plan workflow
2. Check the workflow logs to ensure Azure login succeeds
3. Merge the PR to trigger the apply workflow
4. Verify the apply workflow also succeeds with OIDC

## Benefits of OIDC

✅ **No secrets to rotate**: No client secrets means no expiration
✅ **Better security**: Short-lived tokens instead of long-lived credentials
✅ **Audit trail**: Better tracking of authentication events
✅ **Azure best practice**: Recommended by Microsoft for GitHub Actions

## Troubleshooting

### Error: "AADSTS70021: No matching federated identity record found"

This means the federated credential subject doesn't match. Verify:
- Repository name is correct: `wots-mi/nautilus`
- Branch name matches exactly (for main branch triggers)
- You created the PR credential (for pull request triggers)

### Error: "Insufficient privileges to complete the operation"

The service principal needs appropriate permissions. Run:
```bash
az role assignment list --assignee $APP_ID --all
```

To grant additional permissions if needed:
```bash
az role assignment create \
  --role "Resource Group Contributor" \
  --assignee $APP_ID \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/my-terraform-rg
```

## Reference Links

- [Azure OIDC Documentation](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
