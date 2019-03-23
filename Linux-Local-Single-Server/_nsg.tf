
# Network Security Groups
resource "azurerm_network_security_group" "server" {
  name                = "server"
  location            = "${azurerm_resource_group.dev-env.location}"
  resource_group_name = "${azurerm_resource_group.dev-env.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environmentType = "dev"
  }
}

resource "azurerm_network_security_group" "server_subnet" {
  name                = "server_subnet"
  location            = "${azurerm_resource_group.dev-env.location}"
  resource_group_name = "${azurerm_resource_group.dev-env.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "TCP-Deny"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "UDP-Deny"
    priority                   = 2001
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "UDP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environmentType = "dev"
  }
}



resource "azurerm_subnet_network_security_group_association" "subnet-server" {
  subnet_id                 = "${azurerm_subnet.server.id}"
  network_security_group_id = "${azurerm_network_security_group.server_subnet.id}"
}