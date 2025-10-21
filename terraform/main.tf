# Create Azure Resource Group
# This resource group will contain all infrastructure resources for the project
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.common_tags,
    {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
    }
  )
}
