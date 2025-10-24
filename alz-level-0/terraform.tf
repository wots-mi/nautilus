terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Backend temporarily disabled for initial bootstrap
  # Uncomment after first deployment to migrate state to Azure Storage
  # backend "azurerm" {
  #   use_oidc = true
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = true
      skip_shutdown_and_force_delete = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id            = var.subscription_id_nautilus
  skip_provider_registration = false
}

provider "github" {
  owner = var.github_organization
  token = var.github_token
}
