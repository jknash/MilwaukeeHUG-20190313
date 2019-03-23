

/*
Create network interfaces for the jumpbox and workload servers.  Give them static IP addresses
*/
resource "azurerm_network_interface" "jb-l-ni" {
  count                     = "${var.linux_jumpbox_count}"
  name                      = "${var.linux_jumpbox_prefix}-ni${format("%02d", count.index+1)}"
  location                  = "${azurerm_resource_group.dev-env.location}"
  resource_group_name       = "${azurerm_resource_group.dev-env.name}"
  network_security_group_id = "${element(azurerm_network_security_group.server_jumpbox_linux.*.id, count.index)}"

  ip_configuration {
    name                          = "${var.linux_jumpbox_prefix}-ni-config${format("%02d", count.index+1)}"
    subnet_id                     = "${azurerm_subnet.sn-jumpbox.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.1.${count.index + 4}"
    public_ip_address_id          = "${element(azurerm_public_ip.jumpbox-linux.*.id, count.index)}"
  }
}

resource "azurerm_network_interface" "wl-l-ni" {
  count                     = "${var.linux_workload_count}"
  name                      = "${var.linux_workload_prefix}-ni${format("%02d", count.index+1)}"
  location                  = "${azurerm_resource_group.dev-env.location}"
  resource_group_name       = "${azurerm_resource_group.dev-env.name}"
  network_security_group_id = "${element(azurerm_network_security_group.server_workload_linux.*.id, count.index)}"

  ip_configuration {
    name                          = "${var.linux_workload_prefix}-ni-config${format("%02d", count.index+1)}"
    subnet_id                     = "${azurerm_subnet.sn-wlenv.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.2.${count.index + 4}"
    public_ip_address_id          = "${element(azurerm_public_ip.workload-linux.*.id, count.index)}"
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
      key_data = "${file("../../ssh/tfmeetup/devenv.pub")}"
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
      key_data = "${file("../../ssh/tfmeetup/devenv.pub")}"
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
  name                 = "${var.linux_workload_prefix}-bootstrap${format("%02d", count.index+1)}"
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
        "fileUris": ["https://tfmeetup.blob.core.windows.net/scripts/linux/bootstrap/bootstrap-puppet-server.sh","https://tfmeetup.blob.core.windows.net/scripts/linux/bootstrap/puppet-site/site.pp","https://tfmeetup.blob.core.windows.net/scripts/linux/bootstrap/puppet-conf/puppet-master.conf"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "sudo bash bootstrap-puppet-server.sh ${element(azurerm_dns_a_record.workload-internal.*.name, count.index)}.${azurerm_dns_zone.internal-zone.name}",
      "storageAccountName": "${var.infra_storage_account_name}",
      "storageAccountKey": "${data.vault_generic_secret.workload_storage_account_key.data["key"]}"
    }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "jumpbox-servers-bootstrap" {
  count                = "${var.linux_jumpbox_count}"
  name                 = "${var.linux_jumpbox_prefix}-bootstrap${format("%02d", count.index+1)}"
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
        "fileUris": ["https://tfmeetup.blob.core.windows.net/scripts/linux/bootstrap/bootstrap-standard-server.sh","https://tfmeetup.blob.core.windows.net/keys/id_rsa","https://tfmeetup.blob.core.windows.net/scripts/linux/bootstrap/puppet-conf/puppet-agent.conf"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "sudo bash bootstrap-standard-server.sh ${element(azurerm_dns_a_record.workload-internal.*.name, count.index)}.${azurerm_dns_zone.internal-zone.name} ${element(azurerm_dns_a_record.jumpbox-internal.*.name, count.index)}.${azurerm_dns_zone.internal-zone.name}",
      "storageAccountName": "${var.infra_storage_account_name}",
      "storageAccountKey": "${data.vault_generic_secret.workload_storage_account_key.data["key"]}"
    }
PROTECTED_SETTINGS
}



