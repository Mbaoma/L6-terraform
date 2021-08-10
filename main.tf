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

resource "azurerm_resource_group" "MultipleVM1" {
  name     = "MultipleVM1rg"
  location = "UK South"
}

resource "azurerm_virtual_network" "MultipleVM1" {
  name                = "multipleVM1vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.MultipleVM1.location
  resource_group_name = azurerm_resource_group.MultipleVM1.name
}

resource "azurerm_subnet" "MultipleVM1" {
  name                 = "multipleVM1sub"
  resource_group_name  = azurerm_resource_group.MultipleVM1.name
  virtual_network_name = azurerm_virtual_network.MultipleVM1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "MultipleVM1" {
  name                = "publicIPForLB"
  location            = azurerm_resource_group.MultipleVM1.location
  resource_group_name = azurerm_resource_group.MultipleVM1.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "MultipleVM1" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.MultipleVM1.location
  resource_group_name = azurerm_resource_group.MultipleVM1.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.MultipleVM1.id
  }
}

resource "azurerm_lb_backend_address_pool" "MultipleVM1" {
  #resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id = azurerm_lb.MultipleVM1.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface" "MultipleVM1" {
  count               = 4
  name                = "acctni${count.index}"
  location            = azurerm_resource_group.MultipleVM1.location
  resource_group_name = azurerm_resource_group.MultipleVM1.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.MultipleVM1.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "MultipleVM1" {
  count                = 4
  name                 = "datadisk_existing_${count.index}"
  location             = azurerm_resource_group.MultipleVM1.location
  resource_group_name  = azurerm_resource_group.MultipleVM1.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_availability_set" "avset" {
  name                         = "MultipleVM1set"
  location                     = azurerm_resource_group.MultipleVM1.location
  resource_group_name          = azurerm_resource_group.MultipleVM1.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "MultipleVM1" {
  count                 = 4
  name                  = "acctvm${count.index}"
  location              = azurerm_resource_group.MultipleVM1.location
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = azurerm_resource_group.MultipleVM1.name
  network_interface_ids = [element(azurerm_network_interface.MultipleVM1.*.id, count.index)]
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
    name            = element(azurerm_managed_disk.MultipleVM1.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.MultipleVM1.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.MultipleVM1.*.disk_size_gb, count.index)
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