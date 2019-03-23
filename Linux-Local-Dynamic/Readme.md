This project is meant to run in Azure Cloud shell.  It should work as-is with the exception of access to a storage account for downloading the puppet bootstrap files.  You will need to setup an Azure Keyvault with a secret and then reconfigure _main.tf to access your vault.

This demo was designed to:

- Show how to rapidly create multiple copies of the same VM type (Jumpbox and Workload)
- Show integration with Hashicorp Vault in terraform
- Provision a set number of jumbox and workload VMs (IaaS)
- Demonstrate creating and managing DNS zones and records in Azure DNS (Paas)
- Show bootstrapping a server through the VM script extension in Azure
- Show securing vm and subnet access through Network Security Groups

- The fileUris attribute will need to be updated with your own storage account path.  The key file will also need to be put in a secure storage location for download by the bootstrap script.  I used azure storage for the demo.
- You will need to generate your own SSH keys and replace key file path in the VM builds
- This demo creates records in Azure DNS, so you'll want to modify _vars.tf with your zone
- I've included the my Docker compose file if you would like to spin up vault running on consul on your own machine

Replace anything in <> with your own values.