output "vnet_id" {
   value = azurerm_virtual_network.vnet.*.id
}
output "vnet_rg" {
   value = azurerm_resource_group.vnet.name
}
output "vnet_name" {
   value = azurerm_virtual_network.vnet.name
}
output "nsg_id" {
    value = azurerm_network_security_group.nsg.*.id
}

output "nsg_name" {
    value = azurerm_network_security_group.nsg.*.name
}

output "subnet_id" {
    value = azurerm_subnet.subnet.*.id
}

output "subnet_prefix" {
    value = azurerm_subnet.subnet.*.address_prefix
}

output "rg_name" {
    value = azurerm_resource_group.vnet.name
}

output "vnet_cidr" {
    value = azurerm_virtual_network.vnet.address_space
}
