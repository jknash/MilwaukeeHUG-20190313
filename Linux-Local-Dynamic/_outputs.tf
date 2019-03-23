output "workload_external_ip" {
  value = "${azurerm_public_ip.workload-linux.*.ip_address}"
}

output "jumpbox_external_ip" {
  value = "${azurerm_public_ip.jumpbox-linux.*.ip_address}"
}
