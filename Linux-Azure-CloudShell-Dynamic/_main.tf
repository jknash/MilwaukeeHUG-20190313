data "azurerm_key_vault_secret" "tfmeetup" {
  name      = "tfmeetup-key"
  vault_uri = "https://tfmeetup.vault.azure.net/"
}

# Configure the Azure Provider
provider "azurerm" {
}

