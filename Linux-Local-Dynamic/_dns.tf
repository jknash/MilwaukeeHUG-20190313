
resource "azurerm_dns_zone" "rg-zone" {
  name                = "${azurerm_resource_group.dev-env.name}.${var.dns_root_zone}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  zone_type           = "Public"

  tags {
    environment = "${var.tag_environmentType}"
  }
}


resource "azurerm_dns_zone" "external-zone" {
  name                = "${var.dns_external_zone_prefix}.${azurerm_resource_group.dev-env.name}.${var.dns_root_zone}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  zone_type           = "Public"

  tags {
    environment = "${var.tag_environmentType}"
  }
}

resource "azurerm_dns_zone" "internal-zone" {
  name                = "${var.dns_internal_zone_prefix}.${azurerm_resource_group.dev-env.name}.${var.dns_root_zone}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  zone_type           = "Private"

  registration_virtual_network_ids = ["${azurerm_virtual_network.vn-devenv.id}"]

  tags {
    environment = "${var.tag_environmentType}"
  }
}

resource "azurerm_dns_ns_record" "rg-delegation" {
  name = "${azurerm_resource_group.dev-env.name}"
  zone_name = "${var.dns_root_zone}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  ttl = 1
  records = ["${azurerm_dns_zone.rg-zone.name_servers}"]
}

resource "azurerm_dns_ns_record" "external-delegation" {
  name = "${var.dns_external_zone_prefix}"
  zone_name = "${azurerm_dns_zone.rg-zone.name}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  ttl = 1
  records = ["${azurerm_dns_zone.external-zone.name_servers}"]
}


resource "azurerm_dns_a_record" "jumpbox-external" {
  count               = "${var.linux_jumpbox_count}"
  name                = "${var.linux_jumpbox_prefix}${format("%02d", count.index+1)}"
  zone_name           = "${azurerm_dns_zone.external-zone.name}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  ttl                 = 1
  records             = ["${element(azurerm_public_ip.jumpbox-linux.*.ip_address, count.index)}"]
}

resource "azurerm_dns_a_record" "jumpbox-internal" {
  count               = "${var.linux_jumpbox_count}"
  name                = "${var.linux_jumpbox_prefix}${format("%02d", count.index+1)}"
  zone_name           = "${azurerm_dns_zone.internal-zone.name}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  ttl                 = 1
  records             = ["${element(azurerm_network_interface.jb-l-ni.*.private_ip_address, count.index)}"]
}

resource "azurerm_dns_a_record" "workload-external" {
  count               = "${var.linux_workload_count}"
  name                = "${var.linux_workload_prefix}${format("%02d", count.index+1)}"
  zone_name           = "${azurerm_dns_zone.external-zone.name}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  ttl                 = 1
  records             = ["${element(azurerm_public_ip.workload-linux.*.ip_address, count.index)}"]
}

resource "azurerm_dns_a_record" "workload-internal" {
  count               = "${var.linux_workload_count}"
  name                = "${var.linux_workload_prefix}${format("%02d", count.index+1)}"
  zone_name           = "${azurerm_dns_zone.internal-zone.name}"
  resource_group_name = "${data.azurerm_resource_group.prd-dns.name}"
  ttl                 = 1
  records             = ["${element(azurerm_network_interface.wl-l-ni.*.private_ip_address, count.index)}"]
}

