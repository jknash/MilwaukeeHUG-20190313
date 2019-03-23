/*
Build our vnet
*/
resource "azurerm_virtual_network" "vn-devenv" {
  name                = "vn-devenv"
  address_space       = ["10.10.0.0/16"]
  location            = "${azurerm_resource_group.dev-env.location}"
  resource_group_name = "${azurerm_resource_group.dev-env.name}"

  tags {
    environmentType = "${var.tag_environmentType}"
  }
}

/*
Build 2 Subnets:
- Jumpbox
- Workload
*/
resource "azurerm_subnet" "sn-jumpbox" {
  name                      = "sn-jumpbox"
  resource_group_name       = "${azurerm_resource_group.dev-env.name}"
  virtual_network_name      = "${azurerm_virtual_network.vn-devenv.name}"
  address_prefix            = "10.10.1.0/24"
  network_security_group_id = "${azurerm_network_security_group.subnet_jumpbox.id}"
}

resource "azurerm_subnet" "sn-wlenv" {
  name                      = "sn-wlenv"
  resource_group_name       = "${azurerm_resource_group.dev-env.name}"
  virtual_network_name      = "${azurerm_virtual_network.vn-devenv.name}"
  address_prefix            = "10.10.2.0/24"
  network_security_group_id = "${azurerm_network_security_group.subnet_workload.id}"
}

# Public IP Addresses for jump boxes
resource "azurerm_public_ip" "jumpbox-linux" {
  count                        = "${var.linux_jumpbox_count}"
  name                         = "${var.linux_jumpbox_prefix}${format("%02d", count.index+1)}"
  location                     = "${azurerm_resource_group.dev-env.location}"
  resource_group_name          = "${azurerm_resource_group.dev-env.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"

  tags {
    environmentType = "${var.tag_environmentType}"
  }
}

resource "azurerm_public_ip" "workload-linux" {
  count                        = "${var.linux_workload_count}"
  name                         = "${var.linux_workload_prefix}${format("%02d", count.index+1)}"
  location                     = "${azurerm_resource_group.dev-env.location}"
  resource_group_name          = "${azurerm_resource_group.dev-env.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"

  tags {
    environmentType = "${var.tag_environmentType}"
  }
}