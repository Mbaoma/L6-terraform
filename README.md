# L6-terraform
Infrastructure as code, refers to the act of writing scripts to set up your entire infrastructure (from creation of Virtual Machines, to load balancers)when run. This project uses Terraform to set up architecture of a project.

## Spining up a manifest on Azure
-   First, create an [Azure account](www.portal.azure.com)
-   Configure Azure as your provider and create a Resource group
-   Create a Virtual network within a designated address space
- Create a Public IP address
-   Create a Network Security Group and open up port 22 to allow SSH traffic
- Create a Virtual Network Interface Card
- Create a storage account for diagnostics
- Create a virtual machine

### terraform init, plan and apply
```
terraform init
```

```
terraform fmt
```

```
terraform validate
```

```
terraform plan -out main.tfplan
```

```
terraform apply main.tfplan
```

### ssh into your VM
On the Azure portal, open up an Azure terminal and type in the following command, ```az vm show --resource-group azurerm_resource_group name --name myVM -d --query [publicIps] -o tsv``` to view the public IP of your VM.

Then SSH into it by typing, ```ssh admin_username@<publicIps>```

More details can be found on the [Microsoft Learn documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure?source=docs)