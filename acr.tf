# Create a resource group
resource "azurerm_resource_group" "demo" {
  name     = local.acr
  location = local.buildregion
}

resource "random_string" "random-name" {
  length  = 8
  upper   = false
  lower   = false
  number  = true
  special = false
}