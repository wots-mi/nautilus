# Environment Configuration
environment         = "staging"
resource_group_name = "rg-uami-staging"
location            = "eastus"
uami_name           = "uami-nautilus-staging"

# Backend Configuration
backend_storage_account_name = "nautilustfstatestaging"
backend_resource_group_name  = "terraform-state-staging"
backend_container_name       = "tfstate"

# Tags
common_tags = {
  Environment = "staging"
  Project     = "Nautilus"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Repository  = "wots-mi/nautilus"
}
