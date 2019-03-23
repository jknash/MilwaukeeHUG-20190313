/*
Build our vnet
*/
resource "azurerm_virtual_network" "vnet" {
  name                = "vn-devenv"
  address_space       = ["10.10.0.0/16"]
  location            = "${azurerm_resource_group.dev-env.location}"
  resource_group_name = "${azurerm_resource_group.dev-env.name}"

  tags {
    environmentType = "dev"
  }
}

resource "azurerm_subnet" "server" {
  name                      = "server"
  resource_group_name       = "dev-env01"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "10.10.2.0/24"
  network_security_group_id = "${azurerm_network_security_group.server.id}"
}

resource "azurerm_public_ip" "server-public-ip" {
  name                         = "server-public-ip"
  location                     = "${azurerm_resource_group.dev-env.location}"
  resource_group_name          = "${azurerm_resource_group.dev-env.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"

  tags {
    environmentType = "dev"
  }
}