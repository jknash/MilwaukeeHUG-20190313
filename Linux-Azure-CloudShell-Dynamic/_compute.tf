

/*
Create network interfaces for the jumpbox and workload servers.  Give them static IP addresses
*/
resource "azurerm_network_interface" "jb-l-ni" {
  count                     = 1
  name                      = "${var.linux_jumpbox_prefix}-ni${format("%02d", count.index+1)}"
  location                  = "${azurerm_resource_group.dev-env.location}"
  resource_group_name       = "${azurerm_resource_group.dev-env.name}"
  network_security_group_id = "${azurerm_network_security_group.server_jumpbox_linux.id}"

  ip_configuration {
    name                          = "${var.linux_jumpbox_prefix}-ni-config${format("%02d", count.index+1)}"
    subnet_id                     = "${azurerm_subnet.sn-jumpbox.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.1.4"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox-linux.id}"
  }
}

resource "azurerm_network_interface" "wl-l-ni" {
  count                     = "${var.linux_workload_count}"
  name                      = "${var.linux_workload_prefix}-ni${format("%02d", count.index+1)}"
  location                  = "${azurerm_resource_group.dev-env.location}"
  resource_group_name       = "${azurerm_resource_group.dev-env.name}"
  network_security_group_id = "${azurerm_network_security_group.server_workload_linux.id}"

  ip_configuration {
    name                          = "${var.linux_workload_prefix}-ni-config${format("%02d", count.index+1)}"
    subnet_id                     = "${azurerm_subnet.sn-wlenv.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.2.4"
    public_ip_address_id          = "${azurerm_public_ip.workload-linux.id}"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "jumpbox-linux" {
  count                 = "${var.linux_jumpbox_count}"
  name                  = "${var.linux_jumpbox_prefix}${format("%02d", count.index+1)}"
  location              = "${azurerm_resource_group.dev-env.location}"
  resource_group_name   = "${azurerm_resource_group.dev-env.name}"
  network_interface_ids = ["${element(azurerm_network_interface.jb-l-ni.*.id, count.index)}"]
  vm_size               = "Standard_B2s"
  depends_on            = ["azurerm_virtual_machine.wlenv-linux"]

  storage_os_disk {
    name              = "${var.linux_jumpbox_prefix}${format("%02d", count.index+1)}"
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
    computer_name  = "${var.linux_jumpbox_prefix}${format("%02d", count.index+1)}"
    admin_username = "${var.linux_adminname}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.linux_adminname}/.ssh/authorized_keys"
      #REPLACE THIS WITH YOUR OWN PATH --> key_data = "${file("../ssh/devenv.pub")}"
    }
  }

  tags {
    environment      = "${var.tag_environmentType}"
    autoshutdown     = "true"
    autoshutdowntime = "17:00"
  }
}

resource "azurerm_virtual_machine" "wlenv-linux" {
  count                 = "${var.linux_workload_count}"
  name                  = "${var.linux_workload_prefix}${format("%02d", count.index+1)}"
  location              = "${azurerm_resource_group.dev-env.location}"
  resource_group_name   = "${azurerm_resource_group.dev-env.name}"
  network_interface_ids = ["${element(azurerm_network_interface.wl-l-ni.*.id, count.index)}"]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "${var.linux_workload_prefix}${format("%02d", count.index+1)}"
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
    computer_name  = "${var.linux_workload_prefix}${format("%02d", count.index+1)}"
    admin_username = "${var.linux_adminname}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.linux_adminname}/.ssh/authorized_keys"
      #REPLACE THIS WITH YOUR OWN PATH --> key_data = "${file("../ssh/devenv.pub")}"
    }
  }

  tags {
    environment      = "${var.tag_environmentType}"
    autoshutdown     = "true"
    autoshutdowntime = "17:00"
  }
}

resource "azurerm_virtual_machine_extension" "workload-servers-bootstrap" {
  count                = "${var.linux_workload_count}"
  name                 = "${var.linux_workload_prefix}-bootstrap"
  location             = "${azurerm_resource_group.dev-env.location}"
  resource_group_name  = "${azurerm_resource_group.dev-env.name}"
  virtual_machine_name = "${var.linux_workload_prefix}${format("%02d", count.index+1)}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.5"
  depends_on           = ["azurerm_public_ip.workload-linux", "azurerm_virtual_machine.wlenv-linux", "azurerm_dns_a_record.workload-internal"]

  #depends_on           = ["module.linux_vm"]

  settings = <<SETTINGS
    {
        #REPLACE THIS WITH YOUR OWN PATH --> "fileUris": ["https://<REPLACE>.blob.core.windows.net/scripts/linux/bootstrap/bootstrap-puppet-server.sh","https://<REPLACE>.blob.core.windows.net/scripts/linux/bootstrap/puppet-site/site.pp","https://<REPLACE>.blob.core.windows.net/scripts/linux/bootstrap/puppet-conf/puppet-master.conf"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "sudo bash bootstrap-puppet-server.sh ${local.workload_internal_name}",
      "storageAccountName": "${var.infra_storage_account_name}",
      "storageAccountKey": "${data.azurerm_key_vault_secret.tfmeetup.value}"
    }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "jumpbox-servers-bootstrap" {
  count                = "${var.linux_jumpbox_count}"
  name                 = "${var.linux_jumpbox_prefix}-bootstrap"
  location             = "${azurerm_resource_group.dev-env.location}"
  resource_group_name  = "${azurerm_resource_group.dev-env.name}"
  virtual_machine_name = "${var.linux_jumpbox_prefix}${format("%02d", count.index+1)}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.5"
  depends_on           = ["azurerm_virtual_machine_extension.workload-servers-bootstrap", "azurerm_virtual_machine.jumpbox-linux", "azurerm_virtual_machine.wlenv-linux", "azurerm_dns_a_record.workload-internal"]

  #depends_on           = ["module.linux_vm"]

  settings = <<SETTINGS
    {
        "fileUris": ["https://<REPLACE>.blob.core.windows.net/scripts/linux/bootstrap/bootstrap-standard-server.sh","https://<REPLACE>.blob.core.windows.net/keys/id_rsa","https://<REPLACE>.blob.core.windows.net/scripts/linux/bootstrap/puppet-conf/puppet-agent.conf"]
   } 
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "sudo bash bootstrap-standard-server.sh ${local.workload_internal_name} ${local.jumpbox_internal_name}",
      "storageAccountName": "${var.infra_storage_account_name}",
      "storageAccountKey": "${data.azurerm_key_vault_secret.tfmeetup.value}"
    }
PROTECTED_SETTINGS
}



