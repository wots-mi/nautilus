# Azure Configuration - Production Environment
# subscription_id_nautilus - Set via GitHub Secrets (ARM_SUBSCRIPTION_ID)
resource_group_name = "my-terraform-rg-prod"
location            = "switzerlandnorth"
environment         = "prod"

# Backend configuration for state storage
backend_storage_account_name = "nautilustfstateprod"
backend_container_name       = "state"

# Common tags for all resources
# Note: These will be merged with ManagedBy and CreatedAt tags in main.tf
common_tags = {
  Project     = "Nautilus"
  CostCenter  = "Engineering"
  Owner       = "DevOps-Team"
  Environment = "prod"
}
