terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "vijay" {
  name     = "vijayresource"
  location = "West Europe"
  tags = {
    environement = "dev"
  }
}


# creating virtual network (Vnet) 

resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "application-getway-vnet"
  resource_group_name = azurerm_resource_group.vijay.name
  location            = azurerm_resource_group.vijay.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environement = "dev"
  }
}

# Creating multipal subnet in vnet (type = list)

resource "azurerm_subnet" "virtualsubnet1" {
  name                 = "APP-GETvnet1-subnet-1"
  resource_group_name  = azurerm_resource_group.vijay.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes     = ["10.0.0.0/24"]

}

resource "azurerm_network_security_group" "vijay-nsg" {
  name                = "APP-GETvnet1-nsg"
  resource_group_name = azurerm_resource_group.vijay.name
  location            = azurerm_resource_group.vijay.location


  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "vijay-nsg-rule" {
  name                        = "APP-GETvnet1-nsg-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.vijay.name
  network_security_group_name = azurerm_network_security_group.vijay-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "vijay-assocation1" {
  subnet_id                 = azurerm_subnet.virtualsubnet1.id
  network_security_group_id = azurerm_network_security_group.vijay-nsg.id
}

resource "azurerm_network_interface" "vijay-interfaced-1" {
  name                = "vnet1-interface-1"
  location            = azurerm_resource_group.vijay.location
  resource_group_name = azurerm_resource_group.vijay.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.virtualsubnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "dev"
  }

}

resource "azurerm_linux_virtual_machine" "vijhellaymahcine-1" {
  name                  = "vnet1-vm-1"
  resource_group_name   = azurerm_resource_group.vijay.name
  location              = azurerm_resource_group.vijay.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.vijay-interfaced-1.id]

  custom_data = filebase64("customdataimage.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/vijaykey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }

}
