# Environment Configuration
environment         = "prod"
resource_group_name = "rg-uami-prod"
location            = "eastus"
uami_name           = "uami-nautilus-prod"

# Backend Configuration
backend_storage_account_name = "nautilustfstateprod"
backend_resource_group_name  = "terraform-state-prod"
backend_container_name       = "tfstate"

# Tags
common_tags = {
  Environment = "production"
  Project     = "Nautilus"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Repository  = "wots-mi/nautilus"
}
