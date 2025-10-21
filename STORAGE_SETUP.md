# Storage Account Setup for Terraform State

This guide explains how to create and configure the three Azure Storage Accounts used for Terraform state management across different environments.

## Overview

Each environment uses its own dedicated storage account for complete isolation:

- **Dev**: `nautilustfstatedev`
- **Staging**: `nautilustfstatestaging`
- **Production**: `nautilustfstateprod`

All three accounts are in the **same Azure subscription** but provide logical separation of state files.

## Prerequisites

- Azure CLI installed and authenticated
- Contributor or Owner role on the Azure subscription
- Subscription ID: `1f342b69-ac82-4d46-b8c2-4fcdfc07f50d` (or your subscription)

## Quick Setup Script

Run this script to create all three storage accounts at once:

```bash
#!/bin/bash

# Configuration
SUBSCRIPTION_ID="1f342b69-ac82-4d46-b8c2-4fcdfc07f50d"
RESOURCE_GROUP="nautilus-terraform-state-rg"
LOCATION="switzerlandnorth"

# Set active subscription
az account set --subscription $SUBSCRIPTION_ID

# Create resource group for state storage
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Dev storage account
az storage account create \
  --name nautilustfstatedev \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Create Staging storage account
az storage account create \
  --name nautilustfstatestaging \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Create Production storage account
az storage account create \
  --name nautilustfstateprod \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_GRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

echo "✅ All storage accounts created successfully!"

# Create containers in each storage account
for ACCOUNT in nautilustfstatedev nautilustfstatestaging nautilustfstateprod; do
  az storage container create \
    --name state \
    --account-name $ACCOUNT \
    --auth-mode login
  echo "✅ Container 'state' created in $ACCOUNT"
done

echo "🎉 Setup complete! All storage accounts and containers are ready."
```

## Step-by-Step Manual Setup

### 1. Create Resource Group for State Storage

```bash
az group create \
  --name nautilus-terraform-state-rg \
  --location switzerlandnorth
```

### 2. Create Dev Storage Account

```bash
az storage account create \
  --name nautilustfstatedev \
  --resource-group nautilus-terraform-state-rg \
  --location switzerlandnorth \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags Environment=dev Project=Nautilus
```

**Create container:**
```bash
az storage container create \
  --name state \
  --account-name nautilustfstatedev \
  --auth-mode login
```

### 3. Create Staging Storage Account

```bash
az storage account create \
  --name nautilustfstatestaging \
  --resource-group nautilus-terraform-state-rg \
  --location switzerlandnorth \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags Environment=staging Project=Nautilus
```

**Create container:**
```bash
az storage container create \
  --name state \
  --account-name nautilustfstatestaging \
  --auth-mode login
```

### 4. Create Production Storage Account

```bash
az storage account create \
  --name nautilustfstateprod \
  --resource-group nautilus-terraform-state-rg \
  --location switzerlandnorth \
  --sku Standard_GRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags Environment=prod Project=Nautilus
```

**Note:** Production uses `Standard_GRS` (geo-redundant) for additional reliability.

**Create container:**
```bash
az storage container create \
  --name state \
  --account-name nautilustfstateprod \
  --auth-mode login
```

## Configure Access Permissions

Grant your service principal access to each storage account:

```bash
# Get your service principal object ID
SP_OBJECT_ID=$(az ad sp show --id <your-client-id> --query id -o tsv)

# For each storage account, assign Storage Blob Data Contributor role
for ACCOUNT in nautilustfstatedev nautilustfstatestaging nautilustfstateprod; do
  ACCOUNT_ID=$(az storage account show \
    --name $ACCOUNT \
    --resource-group nautilus-terraform-state-rg \
    --query id -o tsv)
  
  az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee $SP_OBJECT_ID \
    --scope $ACCOUNT_ID
  
  echo "✅ Access granted to $ACCOUNT"
done
```

## Storage Account Configuration Details

### Security Settings

All storage accounts are configured with:
- ✅ **HTTPS only**: All connections must use TLS
- ✅ **TLS 1.2 minimum**: Modern encryption standards
- ✅ **Blob encryption**: Data encrypted at rest
- ✅ **No public access**: Containers are private
- ✅ **Firewall**: Optional - can restrict to GitHub IPs

### SKU Differences

| Environment | SKU | Replication | Cost | Reason |
|-------------|-----|-------------|------|--------|
| Dev | Standard_LRS | Locally redundant | Lowest | Dev can be recreated easily |
| Staging | Standard_LRS | Locally redundant | Low | Staging mirrors dev |
| Production | Standard_GRS | Geo-redundant | Higher | Critical data, needs disaster recovery |

### Cost Estimates (Switzerland North)

Approximate monthly costs:
- **Dev (LRS)**: ~$0.50 - $1.00/month
- **Staging (LRS)**: ~$0.50 - $1.00/month
- **Production (GRS)**: ~$1.00 - $2.00/month

State files are typically very small (< 1 MB), so costs are minimal.

## State File Structure

After setup, each storage account will contain:

```
nautilustfstatedev/
└── state/
    └── terraform.tfstate

nautilustfstatestaging/
└── state/
    └── terraform.tfstate

nautilustfstateprod/
└── state/
    └── terraform.tfstate
```

## Verify Setup

Check that all storage accounts exist:

```bash
az storage account list \
  --resource-group nautilus-terraform-state-rg \
  --output table
```

Expected output:
```
Name                      ResourceGroup                  Location          Sku            AccessTier
------------------------  ----------------------------  ----------------  -------------  ------------
nautilustfstatedev        nautilus-terraform-state-rg   switzerlandnorth  Standard_LRS   Hot
nautilustfstatestaging    nautilus-terraform-state-rg   switzerlandnorth  Standard_LRS   Hot
nautilustfstateprod       nautilus-terraform-state-rg   switzerlandnorth  Standard_GRS   Hot
```

Check containers:

```bash
az storage container list \
  --account-name nautilustfstatedev \
  --auth-mode login \
  --output table
```

Expected output:
```
Name    Lease Status    Last Modified
------  --------------  -------------------------
state   unlocked        2025-10-21T...
```

## Migrating Existing State

If you already have state in `nautilustfstatedev` under `dev/terraform.tfstate`, migrate it:

### Option 1: Copy State File

```bash
# Download existing state
az storage blob download \
  --account-name nautilustfstatedev \
  --container-name state \
  --name dev/terraform.tfstate \
  --file terraform.tfstate.backup \
  --auth-mode login

# Upload to new location (root of container)
az storage blob upload \
  --account-name nautilustfstatedev \
  --container-name state \
  --name terraform.tfstate \
  --file terraform.tfstate.backup \
  --auth-mode login \
  --overwrite
```

### Option 2: Let Terraform Re-initialize

Simply run `terraform init` with the new backend config. Terraform will detect the change and migrate automatically.

## Backup and Disaster Recovery

### Enable Soft Delete (Recommended)

```bash
az storage account blob-service-properties update \
  --account-name nautilustfstateprod \
  --resource-group nautilus-terraform-state-rg \
  --enable-delete-retention true \
  --delete-retention-days 30
```

This keeps deleted state files for 30 days for recovery.

### Enable Versioning (Production)

```bash
az storage account blob-service-properties update \
  --account-name nautilustfstateprod \
  --resource-group nautilus-terraform-state-rg \
  --enable-versioning true
```

Keeps all versions of state file for rollback.

## Troubleshooting

### Error: "Storage account name already taken"

Storage account names are globally unique. If the names are taken:

1. Choose different names (e.g., add suffix: `nautilustfstatedev01`)
2. Update `terraform/*.tfvars` files with new names
3. Re-run the setup script

### Error: "Authorization failed"

Ensure your service principal has:
- `Storage Blob Data Contributor` role on the storage accounts
- Or use `Storage Account Contributor` for broader access

### State Lock Issues

If you encounter state lock errors:

```bash
# List locks
az storage blob list \
  --account-name nautilustfstatedev \
  --container-name state \
  --auth-mode login

# Force unlock (use with caution!)
terraform force-unlock <lock-id>
```

## Security Best Practices

1. ✅ **Separate resource group**: Keep state storage in dedicated RG
2. ✅ **RBAC**: Use role assignments, not access keys
3. ✅ **Network restrictions**: Consider firewall rules for production
4. ✅ **Monitoring**: Enable diagnostic settings for production
5. ✅ **Backup**: Enable soft delete and versioning for production
6. ✅ **Audit**: Review access logs periodically

## Next Steps

After creating storage accounts:

1. ✅ Verify all three accounts exist
2. ✅ Verify containers are created
3. ✅ Grant service principal access
4. ✅ Test Terraform init with new backend config
5. ✅ Configure GitHub Environments (see DEPLOYMENT_GUIDE.md)

## Reference

- [Azure Storage Account Documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Terraform Azure Backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html)
- [Storage Account Security](https://learn.microsoft.com/en-us/azure/storage/common/storage-security-guide)
