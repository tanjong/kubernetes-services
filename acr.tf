# Create a resource group
resource "azurerm_resource_group" "devlab-democluster-rg" {
  name     = local.acr
  location = local.buildregion
}

resource "random_string" "random-name" {
  length  = 8
  upper   = false
  lower   = false
  numeric  = true
  special = false
}