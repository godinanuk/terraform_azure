locals {
  env = "${var.prefix}-fs"
}

module "fs_hub_vnet" {
    source              = "./modules/vnet"
    vnet_name           = "${local.env}-hub-vnet"
    resource_group_name = "${local.env}-hub-rg"
    location            = var.location
    dns_servers         = ["8.8.8.8"]
    address_space       = cidrsubnet(var.fs_hub_cidr, 3, 0)
    subnet_names        = ["${local.env}-Jumpbox-Subnet","${local.env}-vm-subnet"]
    tags                = {
    environment = var.prefix
    function = "full stack network"
    }
}

resource "azurerm_subnet" "gwsubnet" {
  name                      = "GatewaySubnet"
  virtual_network_name      = "${local.env}-hub-vnet"
  resource_group_name       = "${local.env}-hub-rg"
  address_prefixes          = [cidrsubnet(module.fs_hub_vnet.vnet_cidr[0], 2, 3)]
}

resource "azurerm_public_ip" "vpgngwpip" {
    name                =  "vpngwpip"
    location            =  var.location
    resource_group_name =  module.fs_hub_vnet.vnet_rg 
    allocation_method   =  "Dynamic"
}

# VNET configuration, create the resource_group, vnet and subnets
module "fs_spoke100_vnet" {
    source              = "./modules/vnet"
    vnet_name           = "${local.env}-spoke100-vnet"
    resource_group_name = "${local.env}-spoke100-rg"
    location            = var.location
    dns_servers         = ["8.8.8.8"]
    address_space       = cidrsubnet(var.fs_spoke100_cidr, 3, 0)
    subnet_names        = ["${local.env}-spoke100-vm-subnet"]
    tags                = {
    environment = var.prefix
    function = "full stack network"
    }
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                         = "${module.fs_spoke100_vnet.vnet_name}-to-${module.fs_hub_vnet.vnet_name}"
  resource_group_name          = module.fs_spoke100_vnet.vnet_rg
  virtual_network_name         = module.fs_spoke100_vnet.vnet_name 
  remote_virtual_network_id    = element(module.fs_hub_vnet.vnet_id, 0) 
  allow_virtual_network_access = true
  use_remote_gateways          = true
  allow_forwarded_traffic      = true

}

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                         = "${module.fs_hub_vnet.vnet_name}-to-${module.fs_spoke100_vnet.vnet_name}"
  resource_group_name          = module.fs_hub_vnet.vnet_rg
  virtual_network_name         = module.fs_hub_vnet.vnet_name 
  remote_virtual_network_id    = element(module.fs_spoke100_vnet.vnet_id, 0) 
  allow_virtual_network_access = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

module "ssh_rule" {
    source                              = "./modules/nsgrule-complex"
    NSGRuleName                         = "SSH_Rule"
    NSGRulePriority                     = "110"
    NSGRuleDirection                    = "inbound"
    NSGRuleAccess                       = "Allow"
    NSGRuleProtocol                     = "*"
    NSGRuleSourcePortRange              = "*"
    NSGRuleDestinationPortRanges        = ["22"]
    NSGRuleSourceAddressPrefixes        = ["0.0.0.0/0"]
    RGName                              = module.fs_spoke100_vnet.rg_name
    NSGReference                        = module.fs_spoke100_vnet.nsg_name[0]
}

module "ssh_rule2" {
    source                              = "./modules/nsgrule-complex"
    NSGRuleName                         = "SSH_Rule"
    NSGRulePriority                     = "110"
    NSGRuleDirection                    = "inbound"
    NSGRuleAccess                       = "Allow"
    NSGRuleProtocol                     = "*"
    NSGRuleSourcePortRange              = "*"
    NSGRuleDestinationPortRanges        = ["22"]
    NSGRuleSourceAddressPrefixes        = ["0.0.0.0/0"]
    RGName                              = module.fs_hub_vnet.rg_name
    NSGReference                        = module.fs_hub_vnet.nsg_name[1]
}

module "HTTP_rule" {
    source                              = "./modules/nsgrule-complex"
    NSGRuleName                         = "HTTP_Rule"
    NSGRulePriority                     = "120"
    NSGRuleDirection                    = "inbound"
    NSGRuleAccess                       = "Allow"
    NSGRuleProtocol                     = "*"
    NSGRuleSourcePortRange              = "*"
    NSGRuleDestinationPortRanges        = ["80"]
    NSGRuleSourceAddressPrefixes        = ["0.0.0.0/0"]
    RGName                              = module.fs_spoke100_vnet.rg_name
    NSGReference                        = module.fs_spoke100_vnet.nsg_name[0]
}

module "VNC_rule" {
    source                              = "./modules/nsgrule-complex"
    NSGRuleName                         = "VNC_Rule"
    NSGRulePriority                     = "130"
    NSGRuleDirection                    = "inbound"
    NSGRuleAccess                       = "Allow"
    NSGRuleProtocol                     = "*"
    NSGRuleSourcePortRange              = "*"
    NSGRuleDestinationPortRanges        = ["5901"]
    NSGRuleSourceAddressPrefixes        = ["0.0.0.0/0"]
    RGName                              = module.fs_hub_vnet.rg_name
    NSGReference                        = module.fs_hub_vnet.nsg_name[1]
}

resource "azurerm_virtual_network_gateway" "vpngw" {
    name                = "${local.env}-vpngw"
    location            = var.location
    resource_group_name = "${local.env}-hub-rg"
    tags                = {
    Environment = var.prefix
    function = "HUB network"
    }

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "Basic"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpgngwpip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gwsubnet.id
    }

    vpn_client_configuration {
    address_space       = [cidrsubnet(var.fs_hub_cidr, 3, 7)]
    vpn_client_protocols = ["SSTP"]
    }
}

