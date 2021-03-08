resource "azurerm_network_security_rule" "nsg_rule" {
    name                            = var.NSGRuleName
    priority                        = var.NSGRulePriority
    direction                       = var.NSGRuleDirection
    access                          = var.NSGRuleAccess
    protocol                        = var.NSGRuleProtocol
    source_port_range              = var.NSGRuleSourcePortRange
    destination_port_ranges          = var.NSGRuleDestinationPortRanges
    source_address_prefixes          = var.NSGRuleSourceAddressPrefixes
    destination_address_prefix     = var.NSGRuleDestinationAddressPrefix
    resource_group_name             = var.RGName
    network_security_group_name     = var.NSGReference

}
