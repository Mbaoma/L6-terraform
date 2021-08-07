# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "TerraformGroup" {
    name     = "TerraformRG1"
    location = "uksouth"

    tags = {
        environment = "Terraform Demo"
    }
}
# Create virtual network
resource "azurerm_virtual_network" "Terraformnetwork" {
    name                = "Vnet1"
    address_space       = ["10.0.0.0/16"]
    location            = "uksouth"
    resource_group_name = azurerm_resource_group.TerraformGroup.name

    tags = {
        environment = "Terraform Demo"
    }
}
# Create subnet
resource "azurerm_subnet" "Terraformsubnet" {
    name                 = "Subnet1"
    resource_group_name  = azurerm_resource_group.TerraformGroup.name
    virtual_network_name = azurerm_virtual_network.Terraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}
# Create public IP address
resource "azurerm_public_ip" "TerraformpublicIP" {
    name                         = "PublicIP1"
    location                     = "uksouth"
    resource_group_name          = azurerm_resource_group.TerraformGroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "TerraformNSG" {
    name                = "NetworkSecurityGroup1"
    location            = "uksouth"
    resource_group_name = azurerm_resource_group.TerraformGroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}
# Create network interface
resource "azurerm_network_interface" "TerraformNIC" {
    name                        = "NIC1"
    location                    = "uksouth"
    resource_group_name         = azurerm_resource_group.TerraformGroup.name

    ip_configuration {
        name                          = "NicConfiguration1"
        subnet_id                     = azurerm_subnet.Terraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.TerraformpublicIP.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example1" {
    network_interface_id      = azurerm_network_interface.TerraformNIC.id
    network_security_group_id = azurerm_network_security_group.TerraformNSG.id
}
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.TerraformGroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "Storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.TerraformGroup.name
    location                    = "uksouth"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform Demo"
    }
}
# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "TerraformVM1" {
    name                  = "VM1"
    location              = "uksouth"
    resource_group_name   = azurerm_resource_group.TerraformGroup.name
    network_interface_ids = [azurerm_network_interface.TerraformNIC.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "VM1"
    admin_username = "omar"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "omar"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}
