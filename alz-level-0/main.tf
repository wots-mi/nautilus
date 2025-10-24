# Data source to get current subscription
data "azurerm_subscription" "current" {}

# Create Resource Group for Bootstrap Infrastructure
# This resource group contains the managed identity used to bootstrap and deploy other Azure resources
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
      Purpose   = "Bootstrap - User Assigned Managed Identity"
    }
  )
}

# Create Resource Group for Terraform State Storage
# This resource group contains the storage account for Terraform remote state
resource "azurerm_resource_group" "tfstate" {
  name     = var.backend_resource_group_name
  location = var.location

  tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
      Purpose   = "Terraform Remote State Storage"
    }
  )
}

# Create Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = var.backend_storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 30
    }
    
    container_delete_retention_policy {
      days = 30
    }
  }

  tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
      Purpose   = "Terraform State Storage"
    }
  )
}

# Create Blob Container for Terraform State
resource "azurerm_storage_container" "tfstate" {
  name                  = var.backend_container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Create User Assigned Managed Identity for GitHub Actions
# This UAMI is used by GitHub Actions workflows to authenticate to Azure and deploy infrastructure
resource "azurerm_user_assigned_identity" "this" {
  name                = var.uami_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
      Purpose   = "GitHub Actions OIDC Authentication"
    }
  )
}

# Assign Contributor role to UAMI at subscription scope
resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}

# Assign User Access Administrator role to UAMI at subscription scope
resource "azurerm_role_assignment" "user_access_admin" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "User Access Administrator"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}

# Assign Storage Blob Data Contributor role to UAMI on the state storage account
resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}

# Assign Contributor role to UAMI on the state resource group
resource "azurerm_role_assignment" "tfstate_rg_contributor" {
  scope                = azurerm_resource_group.tfstate.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}

# Create Federated Identity Credential for GitHub Actions
resource "azurerm_federated_identity_credential" "github_actions" {
  name                = "github-actions-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.this.id
  subject             = "repo:${var.github_organization}/${var.github_repository}:environment:${var.environment}"

  depends_on = [
    azurerm_user_assigned_identity.this
  ]
}

# GitHub Repository Data Source
data "github_repository" "repo" {
  full_name = "${var.github_organization}/${var.github_repository}"
}

# Create GitHub Environment
resource "github_repository_environment" "this" {
  repository  = data.github_repository.repo.name
  environment = var.environment

  depends_on = [
    azurerm_federated_identity_credential.github_actions,
    azurerm_role_assignment.contributor,
    azurerm_role_assignment.user_access_admin,
    azurerm_role_assignment.storage_blob_contributor,
    azurerm_role_assignment.tfstate_rg_contributor
  ]
}

# Add ARM_CLIENT_ID secret to GitHub Environment
resource "github_actions_environment_secret" "arm_client_id" {
  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.this.environment
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azurerm_user_assigned_identity.this.client_id
}

# Add ARM_TENANT_ID secret to GitHub Environment
resource "github_actions_environment_secret" "arm_tenant_id" {
  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.this.environment
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = azurerm_user_assigned_identity.this.tenant_id
}

# Add ARM_SUBSCRIPTION_ID secret to GitHub Environment
resource "github_actions_environment_secret" "arm_subscription_id" {
  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.this.environment
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}