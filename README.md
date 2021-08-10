# L6-terraform
Infrastructure as code, refers to the act of writing scripts to set up your entire infrastructure (from creation of Virtual Machines, to load balancers)when run. This project uses Terraform to set up architecture of a project.

Due to my subscription, I will provision 5 different resource groups with 4VMs each.

## Spining up multiple manifests on Azure (Azure VM cluster)
-   First, create an [Azure account](www.portal.azure.com)
-   Create an Azure provider and a resource group
-   Create a Virtual network within a designated address space
- Create a Public IP address
- Create a load balancer
- Create a Network Interface and asign count to 20
- Create a Managed disk and asign count to 20
- Create an availability set
- Create a virtual machine and assign count to 20 since we want to provision a cluster of 20 VMs

**You might be asked to login to your Azure account, run the code below to login:**
```
az login
```

### terraform init, plan and apply
```
terraform init
```

```
terraform fmt
terraform validate
```
![image](https://user-images.githubusercontent.com/49791498/128911665-07a63c63-6fe9-4adf-a52e-4ce9d7417ca7.png)

```
terraform plan -out main2.tfplan
```
![image](https://user-images.githubusercontent.com/49791498/128911897-f4a7d1ff-2d36-4955-8211-3c85dd4be782.png)

```
terraform apply main2.tfplan
```
![image](https://user-images.githubusercontent.com/49791498/128908749-949dca13-7abe-4556-b281-317fb979ad1d.png)

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

### Running instance
![image](https://user-images.githubusercontent.com/49791498/128909272-69b27bd8-818e-413e-86fc-78540c2d2f94.png)

More details can be found on the [Microsoft Learn website](https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure?source=docs).

Read up on [SSH Keys](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed) on the Microsoft Learn Website