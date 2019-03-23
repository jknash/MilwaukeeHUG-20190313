# Resource Groups
resource "azurerm_resource_group" "dev-env" {
    name = "${var.devenv_rg_name}"
    location = "${var.devenv_location}"
}