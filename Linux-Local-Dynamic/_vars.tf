variable "devenv_location" {
  default = "eastus"
}

variable "devenv_rg_name" {
  default = "dev-env09"
}
variable "tag_environmentType" {
  default = "development"
}

variable "linux_jumpbox_count" {
  default = 2
}

variable "linux_workload_count" {
  default = 2
}

variable "linux_jumpbox_prefix" {
  default = "jb-l"
}

variable "linux_devserver_prefix" {
  default = "devenv-l"
}

variable "linux_workload_prefix" {
  default = "wl-l"
}

variable "linux_adminname" {
  default = "azuser"
}
variable dsc_config {
  default = "node_configuration_you_want_applied__can_leave_blank"
}

variable dsc_mode {
  default = "applyAndMonitor"
}

variable infra_storage_account_address {
  default = "https://tfmeetup.blob.core.windows.net"
}

variable infra_storage_account_name {
  default = "tfmeetup"
}

variable dns_root_zone {
  #REPLACE THIS WITH YOUR OWN PATH --> default = "example.com"
}

variable dns_internal_zone_prefix {
  default = "int09"
}

variable dns_external_zone_prefix {
  default = "ext09"
}
