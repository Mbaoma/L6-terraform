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
- Create public SSH key by running:
```
ssh-keygen -m PEM -t rsa -b 4096
```
- Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt) to build the AzureRM client

### terraform init, plan and apply
```
terraform init
```
![image](https://user-images.githubusercontent.com/49791498/128585417-5a810b1b-534a-424f-a280-96cd75a061c7.png)

```
terraform fmt
```
![image](https://user-images.githubusercontent.com/49791498/128585457-ec6e6d65-de03-416d-b709-61d76d36a907.png)

```
terraform validate
```
![image](https://user-images.githubusercontent.com/49791498/128585806-88725d89-6ba3-405e-bd11-588d9741d6f9.png)

```
terraform plan -out main.tfplan
```
![image](https://user-images.githubusercontent.com/49791498/128586083-53f02070-17c4-412f-a971-12825b51de3d.png)

```
terraform apply main.tfplan
```

![image](https://user-images.githubusercontent.com/49791498/128586217-0e8539ae-b72c-4b55-a34b-26cfaf97d114.png)

![image](https://user-images.githubusercontent.com/49791498/128586206-5d97957f-561c-4113-898a-7be30f67e8ed.png)


### ssh into your VM
On the Azure portal, open up an Azure terminal and type in the following command, ```az vm show --resource-group azurerm_resource_group name --name vm_name -d --query [publicIps] -o tsv``` to view the public IP of your VM.
![image](https://user-images.githubusercontent.com/49791498/128586473-aa24af6a-b619-45f2-ab38-76569c14b186.png)

Then SSH into your VM by typing, ```ssh -i <path to public SSH key> <admin_username>@<public IP address>``` on your terminal
![image](https://user-images.githubusercontent.com/49791498/128588189-6d6b5baf-b303-4c1c-8cf2-80ebb4a6b2e4.png)

### Running instance
![image](https://user-images.githubusercontent.com/49791498/128589372-8e889b20-05c1-415f-88fc-13c876d1ce70.png)

More details can be found on the [Microsoft Learn website](https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure?source=docs).

Read up on [SSH Keys](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed) on the Microsoft Learn Website