# L6-terraform
Infrastructure as code, refers to the act of writing scripts to set up your entire infrastructure (from creation of Virtual Machines, to load balancers)when run. This project uses Terraform to set up architecture of a project.

## Spining up multiple manifests on Azure (Azure VM cluster)
-   First, create an [Azure account](www.portal.azure.com)
-   Create an Azure provider and a resource group
-   Create a Virtual network within a designated address space
- Create a Public IP address
- Create a load balancer
- Create a Network Interface and asign count to 2
- Create a Managed disk and asign count to 2
- Create an availability set
- Create a virtual machine and assign count to 20 since we want to provision a cluster of 20 VMs

### terraform init, plan and apply
```
terraform init
```
![image](https://user-images.githubusercontent.com/49791498/128607666-01614ae4-6096-4be3-afd3-1a87cf150d21.png)

```
terraform fmt
```
![image](https://user-images.githubusercontent.com/49791498/128607977-7a9bfb6b-9222-4ea8-a8dd-e1f21d826679.png)

```
terraform validate
```
![image](https://user-images.githubusercontent.com/49791498/128608395-91aae77c-17aa-4ed3-97e9-7949dcc9112d.png)

```
terraform plan -out main.tfplan
```
![image](https://user-images.githubusercontent.com/49791498/128608523-90ab45ed-006b-4f79-a39a-6725d0ba11cd.png)

```
terraform apply main.tfplan
```

### Large file error
If you encounter this error, run the following code:
```
git filter-branch -f --index-filter 'git rm --cached --ignore-unmatch <large file to be ignored>'
```

### import error
If you encounter this error, run the following code:
```
terraform import azurerm_network_interface.<resource name> /subscriptions/<path to file>
```

### ssh into your VM
On the Azure portal, open up an Azure terminal and type in the following command, ```az vm show --resource-group azurerm_resource_group name --name vm_name -d --query [publicIps] -o tsv``` to view the public IP of your VM.
![image](https://user-images.githubusercontent.com/49791498/128586473-aa24af6a-b619-45f2-ab38-76569c14b186.png)

Then SSH into your VM by typing, ```ssh -i <path to public SSH key> <admin_username>@<public IP address>``` on your terminal
![image](https://user-images.githubusercontent.com/49791498/128588189-6d6b5baf-b303-4c1c-8cf2-80ebb4a6b2e4.png)

### Running instance
![image](https://user-images.githubusercontent.com/49791498/128589372-8e889b20-05c1-415f-88fc-13c876d1ce70.png)

More details can be found on the [Microsoft Learn website](https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure?source=docs).

Read up on [SSH Keys](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed) on the Microsoft Learn Website