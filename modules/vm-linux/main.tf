resource "azurerm_public_ip" "pip" {
  name                         = "${var.vm_name}-pip"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  allocation_method = "Static"
  sku                          = "basic"
  tags                         = var.tags
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic-${var.vm_name}"
  resource_group_name = var.resource_group_name 
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id 
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.prefix}-vm-${var.vm_name}"
  resource_group_name             = var.resource_group_name 
  location                        = var.location 
  size                            = "Standard_B1ms"
  admin_username                  = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
