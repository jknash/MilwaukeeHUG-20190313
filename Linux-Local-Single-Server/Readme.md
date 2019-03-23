This project was setup to run locally, but could be modified to run in Cloud Shell.  It is configured to use Vault locally for secret storage and access.  The stuff coming from Vault is for Azure access, anyway so if you are running in Cloud shell, you're pre-authenticated when running Terraform.

This demo was designed to:

- Show a basic 1 single deployment into Azure
- Show integration with vault for secrets

Replace anything in <> with your own values.