# Environment Configuration
environment         = "dev"
resource_group_name = "user-assigned-mi-init"
location            = "switzerlandnorth"
uami_name           = "uai-db-mila"

# Backend Configuration
backend_storage_account_name = "bootstrapsta"
backend_resource_group_name  = "Bootstrap-state"
backend_container_name       = "state"

# Tags
common_tags = {
  Environment = "dev"
  Project     = "Nautilus"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Repository  = "wots-mi/nautilus"
}
