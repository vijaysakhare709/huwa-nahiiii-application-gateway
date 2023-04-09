resource "azurerm_network_interface" "vijay-interfaced-2" {
  name                = "vnet1-interface-2"
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

resource "azurerm_linux_virtual_machine" "vijhellaymahcine-2" {
  name                  = "vnet2-vm-2"
  resource_group_name   = azurerm_resource_group.vijay.name
  location              = azurerm_resource_group.vijay.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.vijay-interfaced-2.id]

  custom_data = filebase64("customdatavideo.tpl")


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
