# Create tls private key
resource "tls_private_key" "tls_ssh_private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
data "tls_public_key" "tls_ssh_public" {
  private_key_pem = tls_private_key.tls_ssh_private.private_key_pem
}


# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.azurerm_virtual_network_name
  address_space       = var.vnet_range
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Name        = var.azurerm_virtual_network_name
    environment = "Terraform Networking"
  }
}

# Create subnet
resource "azurerm_subnet" "tfsubnet" {
  name                 = var.azurerm_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_range
}

# Create storage account
resource "azurerm_storage_account" "stor" {
  name                     = "${azurerm_resource_group.rg.name}stor"
  location                 = var.resource_group_location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create public ip
resource "azurerm_public_ip" "ip" {
  name                = var.azurerm_public_ip
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "nic" {
  name                = "${azurerm_resource_group.rg.name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

locals {
  custom_data = <<-EOL
  #!/bin/bash
  sudo apt update
  sudo apt install -y apache2
  sudo systemctl start apache2
  sudo systemctl enable apache2
  EOL
}


# Create VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.computer_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.azurerm_vm_size
  network_interface_ids = [azurerm_network_interface.nic.id]

  custom_data = base64encode(local.custom_data)


  source_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }

  os_disk {
    name                 = "osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }
  admin_username = var.user_name
  admin_ssh_key {
    username = var.user_name
    #public_key = file("~/.ssh/id_rsa.pub")
    public_key = data.tls_public_key.tls_ssh_public.public_key_openssh
  }
  depends_on = [
    azurerm_public_ip.ip
  ]
}

resource "azurerm_network_security_group" "sg" {
  name                = "${var.resource_group_name_prefix}-sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "Ingress"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges = ["22", "80", "443"]
    #destination_port_range     = security_rule.value
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "sg-asso" {
  subnet_id                 = azurerm_subnet.tfsubnet.id
  network_security_group_id = azurerm_network_security_group.sg.id
  depends_on = [
    azurerm_network_security_group.sg
  ]
}