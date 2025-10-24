variable "subscription_id_nautilus" {
  description = "The Azure subscription ID for the Nautilus project"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the managed identity will be created"
  type        = string
}

variable "location" {
  description = "Azure region where the managed identity will be created"
  type        = string
  default     = "eastus"
}

variable "uami_name" {
  description = "Name of the User Assigned Managed Identity"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Backend configuration variables
variable "backend_storage_account_name" {
  description = "Name of the storage account for Terraform state"
  type        = string
}

variable "backend_resource_group_name" {
  description = "Name of the resource group containing the storage account"
  type        = string
}

variable "backend_container_name" {
  description = "Name of the blob container for Terraform state"
  type        = string
  default     = "tfstate"
}

# GitHub configuration for federated credentials
variable "github_organization" {
  description = "GitHub organization or owner name"
  type        = string
  default     = "wots-mi"
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
  default     = "nautilus"
}

variable "github_token" {
  description = "GitHub Personal Access Token for managing repository settings"
  type        = string
  sensitive   = true
}
