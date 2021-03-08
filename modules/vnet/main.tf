#Azure Generic vNet Module
resource "azurerm_resource_group" "vnet" {
  name     = var.resource_group_name 
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name 
  address_space       = [var.address_space]
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_network_security_group" "nsg" {
   count = length(var.subnet_names)
   name = "${var.subnet_names[count.index]}-nsg"
   resource_group_name = azurerm_resource_group.vnet.name
   location = var.location
   tags     = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_names[count.index] 
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, count.index)]
  count                = length(var.subnet_names)
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg[count.index].id
  count = length(var.subnet_names)
}
