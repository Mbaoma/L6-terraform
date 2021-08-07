# L6-terraform
Infrastructure as code, refers to the act of writing scripts to set up your entire infrastructure (from creation of Virtual Machines, to load balancers)when run. This project uses Terraform to set up architecture of a project.

## Spining up multiple manifests on Azure (Azure VM cluster)
-   First, create an [Azure account](www.portal.azure.com)
-   Call the previously created Resource group ```TerraformGroup```
-   Create a Virtual network within a designated address space
- Create a Public IP address
- Create a load balancer
- Create a Network Interface and asign count to be the number of Network interfaces for your VMs
- Create a Managed disk and asign count to be the number of Network interfaces for your VMs
- Create an availability set
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
On the Azure portal, open up an Azure terminal and type in the following command, ```az vm show --resource-group azurerm_resource_group name --name vm_name -d --query [publicIps] -o tsv``` to view the public IP of your VM.
![image](https://user-images.githubusercontent.com/49791498/128586473-aa24af6a-b619-45f2-ab38-76569c14b186.png)

Then SSH into your VM by typing, ```ssh -i <path to public SSH key> <admin_username>@<public IP address>``` on your terminal
![image](https://user-images.githubusercontent.com/49791498/128588189-6d6b5baf-b303-4c1c-8cf2-80ebb4a6b2e4.png)

### Running instance
![image](https://user-images.githubusercontent.com/49791498/128589372-8e889b20-05c1-415f-88fc-13c876d1ce70.png)

More details can be found on the [Microsoft Learn website](https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure?source=docs).

Read up on [SSH Keys](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed) on the Microsoft Learn Website