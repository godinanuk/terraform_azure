locals {
  env = "${var.prefix}-fs"
}

# VNET configuration, create the resource_group, vnet and subnets
module "fs_vnet" {
    source              = "./modules/vnet"
    vnet_name           = "${local.env}-vnet"
    resource_group_name = "${local.env}-nsec-rg"
    location            = var.location
    dns_servers         = [cidrhost(var.fs_cidr, 4),cidrhost(var.fs_cidr, 5),"8.8.8.8"]
    address_space       = cidrsubnet(var.fs_cidr, 3, 0)
    subnet_names        = ["${local.env}-Jumpbox-Subnet","${local.env}-vm-subnet"]
    tags                = {
    environment = var.prefix
    function = "full stack network"
    }
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
    RGName                              = module.fs_vnet.rg_name
    NSGReference                        = module.fs_vnet.nsg_name[1]
}
