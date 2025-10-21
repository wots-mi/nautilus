# Azure Configuration
subscription_id_nautilus = "1f342b69-ac82-4d46-b8c2-4fcdfc07f50d"
resource_group_name      = "my-terraform-rg"
location                 = "switzerlandnorth"
environment              = "dev"

# Common tags for all resources
common_tags = {
  Project     = "Terraform-Azure"
  Environment = "dev"
  Owner       = "DevOps"
  CostCenter  = "Engineering"
}
