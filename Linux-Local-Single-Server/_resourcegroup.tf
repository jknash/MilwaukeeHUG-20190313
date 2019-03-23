# Resource Groups
resource "azurerm_resource_group" "dev-env" {
    name = "dev-env01"
    location = "eastus"
}