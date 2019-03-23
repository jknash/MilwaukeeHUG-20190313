
# Network Security Groups
resource "azurerm_network_security_group" "server_jumpbox_linux" {
  count               = "${var.linux_jumpbox_count}"
  name                = "server_jumpbox_linux${format("%02d", count.index+1)}"
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
    environmentType = "${var.tag_environmentType}"
  }
}

resource "azurerm_network_security_group" "server_workload_linux" {
  name                = "server_workload_linux"
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
    source_address_prefix      = "10.10.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Puppet"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8140"
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
    environmentType = "${var.tag_environmentType}"
  }
}

resource "azurerm_network_security_group" "subnet_workload" {
  name                = "subnet_workload"
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
    source_address_prefix      = "10.10.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Puppet"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8140"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environmentType = "${var.tag_environmentType}"
  }
}

resource "azurerm_network_security_group" "subnet_jumpbox" {
  name                = "subnet_jumpbox"
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
    environmentType = "${var.tag_environmentType}"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet-jumpboxservers" {
  subnet_id                 = "${azurerm_subnet.sn-jumpbox.id}"
  network_security_group_id = "${azurerm_network_security_group.subnet_jumpbox.id}"
}

resource "azurerm_subnet_network_security_group_association" "subnet-workload" {
  subnet_id                 = "${azurerm_subnet.sn-wlenv.id}"
  network_security_group_id = "${azurerm_network_security_group.subnet_workload.id}"
}