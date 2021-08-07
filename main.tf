# Reference the previously created resource group
resource "azurerm_resource_group" "TerraformGroup" {
 name     = "TerraformRG1"
 location = "uksouth"
}
# Create virtual network
resource "azurerm_virtual_network" "TerraformGroup" {
 name                = "acctvn"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.TerraformGroup.location
 resource_group_name = azurerm_resource_group.TerraformGroup.name
}

# Create subnet
resource "azurerm_subnet" "TerraformGroup" {
 name                 = "acctsub"
 resource_group_name  = azurerm_resource_group.TerraformGroup.name
 virtual_network_name = azurerm_virtual_network.TerraformGroup.name
 address_prefix       = "10.0.2.0/24"
}

# Create public IP address
resource "azurerm_public_ip" "TerraformGroup" {
 name                         = "publicIPForLB"
 location                     = azurerm_resource_group.TerraformGroup.location
 resource_group_name          = azurerm_resource_group.TerraformGroup.name
 allocation_method            = "Static"
}

# Create a load balancer
resource "azurerm_lb" "TerraformGroup" {
 name                = "loadBalancer"
 location            = azurerm_resource_group.TerraformGroup.location
 resource_group_name = azurerm_resource_group.TerraformGroup.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.TerraformGroup.id
 }
}

resource "azurerm_lb_backend_address_pool" "TerraformGroup" {
 resource_group_name = azurerm_resource_group.TerraformGroup.name
 loadbalancer_id     = azurerm_lb.TerraformGroup.id
 name                = "BackEndAddressPool"
}

# Create network interface
resource "azurerm_network_interface" "TerraformGroup" {
 count               = 20
 name                = "acctni${count.index}"
 location            = azurerm_resource_group.TerraformGroup.location
 resource_group_name = azurerm_resource_group.TerraformGroup.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.TerraformGroup.id
   private_ip_address_allocation = "dynamic"
 }
}

# Create a managed disk
resource "azurerm_managed_disk" "TerraformGroup" {
 count                = 20
 name                 = "datadisk_existing_${count.index}"
 location             = azurerm_resource_group.TerraformGroup.location
 resource_group_name  = azurerm_resource_group.TerraformGroup.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
}

# Create an availability set
resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.TerraformGroup.location
 resource_group_name          = azurerm_resource_group.TerraformGroup.name
 platform_fault_domain_count  = 20
 platform_update_domain_count = 20
 managed                      = true
}

# Create a virtual machine 
resource "azurerm_virtual_machine" "TerraformGroup" {
 count                 = 20
 name                  = "acctvm${count.index}"
 location              = azurerm_resource_group.TerraformGroup.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.TerraformGroup.name
 network_interface_ids = [element(azurerm_network_interface.TerraformGroup.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "18.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

# Optional data disks
 storage_data_disk {
   name              = "datadisk_new_${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "1023"
 }

 storage_data_disk {
   name            = element(azurerm_managed_disk.TerraformGroup.*.name, count.index)
   managed_disk_id = element(azurerm_managed_disk.TerraformGroup.*.id, count.index)
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = element(azurerm_managed_disk.TerraformGroup.*.disk_size_gb, count.index)
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = "testadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "staging"
 }
}
