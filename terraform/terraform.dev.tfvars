# Azure Configuration
# subscription_id_nautilus - Set via GitHub Secrets (ARM_SUBSCRIPTION_ID)
resource_group_name = "workload-rg-dev"
location            = "switzerlandnorth"
environment         = "dev"

# Backend configuration for state storage
backend_storage_account_name = "nautilustfstatedev"
backend_resource_group_name  = "terraform-state-dev"
backend_container_name       = "state"

# Common tags for all resources
# Note: These will be merged with ManagedBy and CreatedAt tags in main.tf
common_tags = {
  Project     = "Nautilus"
  CostCenter  = "Engineering"
  Owner       = "DevOps-Team"
  Environment = "dev"
}
