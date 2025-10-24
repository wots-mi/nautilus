# Environment Configuration
environment         = "dev"
resource_group_name = "rg-uami-dev"
location            = "eastus"
uami_name           = "uami-nautilus-dev"

# Backend Configuration
backend_storage_account_name = "nautilustfstatedev"
backend_resource_group_name  = "terraform-state-dev"
backend_container_name       = "tfstate"

# Tags
common_tags = {
  Environment = "dev"
  Project     = "Nautilus"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Repository  = "wots-mi/nautilus"
}
