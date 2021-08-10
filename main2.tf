# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "MultipleVM2" {
  name     = "MultipleVM2rg"
  location = "East US"
}

resource "azurerm_virtual_network" "MultipleVM2" {
  name                = "MultipleVM2vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.MultipleVM2.location
  resource_group_name = azurerm_resource_group.MultipleVM2.name
}

resource "azurerm_subnet" "MultipleVM2" {
  name                 = "MultipleVM2sub"
  resource_group_name  = azurerm_resource_group.MultipleVM2.name
  virtual_network_name = azurerm_virtual_network.MultipleVM2.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "MultipleVM2" {
  name                = "publicIPForLB"
  location            = azurerm_resource_group.MultipleVM2.location
  resource_group_name = azurerm_resource_group.MultipleVM2.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "MultipleVM2" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.MultipleVM2.location
  resource_group_name = azurerm_resource_group.MultipleVM2.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.MultipleVM2.id
  }
}

resource "azurerm_lb_backend_address_pool" "MultipleVM2" {
  #resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id = azurerm_lb.MultipleVM2.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface" "MultipleVM2" {
  count               = 4
  name                = "acctni${count.index}"
  location            = azurerm_resource_group.MultipleVM2.location
  resource_group_name = azurerm_resource_group.MultipleVM2.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.MultipleVM2.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "MultipleVM2" {
  count                = 4
  name                 = "datadisk_existing_${count.index}"
  location             = azurerm_resource_group.MultipleVM2.location
  resource_group_name  = azurerm_resource_group.MultipleVM2.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_availability_set" "avset" {
  name                         = "MultipleVM2set"
  location                     = azurerm_resource_group.MultipleVM2.location
  resource_group_name          = azurerm_resource_group.MultipleVM2.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "MultipleVM2" {
  count                 = 4
  name                  = "acctvm${count.index}"
  location              = azurerm_resource_group.MultipleVM2.location
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = azurerm_resource_group.MultipleVM2.name
  network_interface_ids = [element(azurerm_network_interface.MultipleVM2.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  # Uncomm ent this line to delete the OS disk automatically when deleting the VM
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
    name            = element(azurerm_managed_disk.MultipleVM2.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.MultipleVM2.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.MultipleVM2.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "host"
    admin_username = "oma"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }
}