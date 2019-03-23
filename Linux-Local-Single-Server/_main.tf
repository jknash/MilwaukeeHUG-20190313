data "vault_generic_secret" "arm_subscription_id" {
  path = "secret/tfmeetup/arm_subscription_id"
}

data "vault_generic_secret" "arm_client_secret" {
  path = "secret/tfmeetup/arm_client_secret"
}

data "vault_generic_secret" "arm_environment" {
  path = "secret/xis_terraform_demo/arm_environment"
}

data "vault_generic_secret" "arm_client_id" {
  path = "secret/tfmeetup/arm_client_id"
}

data "vault_generic_secret" "arm_tenant_id" {
  path = "secret/tfmeetup/arm_tenant_id"
}


# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  client_secret = "${data.vault_generic_secret.arm_client_secret.data["secret"]}"
  client_id = "${data.vault_generic_secret.arm_client_id.data["id"]}"
  environment = "${data.vault_generic_secret.arm_environment.data["environment"]}"
  tenant_id = "${data.vault_generic_secret.arm_tenant_id.data["id"]}"
  subscription_id = "${data.vault_generic_secret.arm_subscription_id.data["id"]}"
}

output "tenant_id" {
  value = "${data.vault_generic_secret.arm_tenant_id.data["id"]}"
}

