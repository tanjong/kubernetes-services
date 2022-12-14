# Create a resource group
resource "azurerm_resource_group" "devlab-democluster-acr-rg" {
  name     = local.acr
  location = local.buildregion
}

resource "random_string" "random" {
  length           = 5
  special          = false
  lower            = true
  upper            = "false"
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_container_registry" "demo-app" {
  name                = "demoapp${random_string.random.result}"
  resource_group_name = azurerm_resource_group.devlab-democluster-acr-rg.name
  location            = azurerm_resource_group.devlab-democluster-acr-rg.location
  sku                 = "Standard"
  admin_enabled       = false
}