# Azure Configuration - Staging Environment
# subscription_id_nautilus - Set via GitHub Secrets (ARM_SUBSCRIPTION_ID)
resource_group_name = "my-terraform-rg-staging"
location            = "switzerlandnorth"
environment         = "staging"

# Common tags for all resources
# Note: These will be merged with ManagedBy and CreatedAt tags in main.tf
common_tags = {
  Project     = "Nautilus"
  CostCenter  = "Engineering"
  Owner       = "DevOps-Team"
  Environment = "staging"
}
