variable "subscription_id_nautilus" {
  description = "The subscription ID for the Nautilus subscription"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2,}$", replace(var.location, " ", "")))
    error_message = "Location must be a valid Azure region."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project    = "Nautilus"
    CostCenter = "Engineering"
    Owner      = "DevOps-Team"
  }
}
