# Azure Configuration
# subscription_id_nautilus - Set via GitHub Secrets (ARM_SUBSCRIPTION_ID)
resource_group_name = "my-terraform-rg"
location            = "switzerlandnorth"
environment         = "dev"

# Common tags for all resources
common_tags = {
  Environment = "dev"
}
