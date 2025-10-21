terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote state backend configuration
  # Uncomment and configure for remote state management
  # backend "azurerm" {
  #   resource_group_name  = var.tf_state_resource_group
  #   storage_account_name = var.tf_state_storage_account
  #   container_name       = var.tf_state_container
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    virtual_machine {
      delete_os_disk_on_deletion            = true
      graceful_shutdown                     = true
      skip_shutdown_and_force_delete        = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = "${var.subscription_id_nautilus}"
  skip_provider_registration = false
}
