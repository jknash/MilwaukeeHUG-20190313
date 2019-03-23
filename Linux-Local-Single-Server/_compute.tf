

resource "azurerm_network_interface" "server-nic" {
  name                      = "server-nic"
  location            = "${azurerm_resource_group.dev-env.location}"
  resource_group_name = "${azurerm_resource_group.dev-env.name}"
  network_security_group_id = "${azurerm_network_security_group.server.id}"

  ip_configuration {
    name                          = "server-nic-ipconfig"
    subnet_id                     = "${azurerm_subnet.server.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.2.4"
    public_ip_address_id          = "${azurerm_public_ip.server-public-ip.id}"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "server" {
  name                  = "server"
  location            = "${azurerm_resource_group.dev-env.location}"
  resource_group_name = "${azurerm_resource_group.dev-env.name}"
  network_interface_ids = ["${azurerm_network_interface.server-nic.id}"]
  vm_size               = "Standard_B2s"
  
  storage_os_disk {
    name              = "server-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "server01"
    admin_username = "azuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azuser/.ssh/authorized_keys"
      key_data = "${file("../../ssh/tfmeetup/devenv.pub")}"
    }
  }

  tags {
    environment      = "dev"
    autoshutdown     = "true"
    autoshutdowntime = "17:00"
  }
}



