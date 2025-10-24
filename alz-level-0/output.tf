output "uami_id" {
  description = "The ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.this.id
}

output "uami_principal_id" {
  description = "The Principal ID (Object ID) of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "uami_client_id" {
  description = "The Client ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "uami_tenant_id" {
  description = "The Tenant ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.this.tenant_id
}

output "resource_group_name" {
  description = "The name of the resource group containing the managed identity"
  value       = azurerm_resource_group.this.name
}

output "subscription_id" {
  description = "The subscription ID where roles are assigned"
  value       = data.azurerm_subscription.current.subscription_id
}

output "role_assignments" {
  description = "Summary of role assignments"
  value = {
    contributor = {
      role  = "Contributor"
      scope = data.azurerm_subscription.current.id
    }
    user_access_administrator = {
      role  = "User Access Administrator"
      scope = data.azurerm_subscription.current.id
    }
  }
}

output "federated_credential" {
  description = "Federated identity credential details for GitHub Actions"
  value = {
    name     = azurerm_federated_identity_credential.github_actions.name
    subject  = azurerm_federated_identity_credential.github_actions.subject
    issuer   = azurerm_federated_identity_credential.github_actions.issuer
    audience = azurerm_federated_identity_credential.github_actions.audience
  }
}

output "github_environment" {
  description = "GitHub Environment configuration"
  value = {
    repository  = data.github_repository.repo.full_name
    environment = github_repository_environment.this.environment
    secrets_configured = [
      "ARM_CLIENT_ID",
      "ARM_TENANT_ID",
      "ARM_SUBSCRIPTION_ID"
    ]
  }
}

output "storage_account" {
  description = "Terraform state storage account details"
  value = {
    name                = azurerm_storage_account.tfstate.name
    resource_group_name = azurerm_resource_group.tfstate.name
    container_name      = azurerm_storage_container.tfstate.name
    primary_blob_endpoint = azurerm_storage_account.tfstate.primary_blob_endpoint
  }
}

output "backend_config" {
  description = "Backend configuration for other Terraform workspaces"
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
    key                  = "terraform.tfstate"
  }
}
