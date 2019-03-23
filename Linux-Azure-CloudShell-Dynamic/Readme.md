This project is meant to run in Azure Cloud shell.  It should work as-is with the exception of access to a storage account for downloading the puppet bootstrap files.  You will need to setup an Azure Keyvault with a secret and then reconfigure _main.tf to access your vault.

This demo was designed to:

- Show how teraform works within the Azure cloud shell environment
- Show integration with Azure Key Vault for storing secrets
- Provision a jumbox and workload VM (IaaS)
- Demonstrate creating and managing DNS zones and records in Azure DNS (Paas)
- Show bootstrapping a server through the VM script extension in Azure
- Show securing vm and subnet access through Network Security Groups

- The fileUris attribute will need to be updated with your own storage account path.  The key file will also need to be put in a secure storage location for download by the bootstrap script.  I used azure storage for the demo.
- You will need to generate your own SSH keys and replace key file path in the VM builds
- This demo creates records in Azure DNS, so you'll want to modify _vars.tf with your zone

Replace anything in <> with your own values.

To setup Azure Cloud shell in your own evironment: https://docs.microsoft.com/en-us/azure/cloud-shell/overview