resource "azurerm_resource_group" "vm_rg" {
  name     = "${var.prefix}-vm-rg"
  location = var.location
  tags = {
    Environment = var.prefix
    function    = "Full Stack Resource Group"
  }
}

module "db-vm" {
  source = "./modules/vm-linux"
  vm_name = "db-vm"
  location = var.location 
  prefix = var.prefix
  resource_group_name = azurerm_resource_group.vm_rg.name
  subnet_id           = module.fs_vnet.subnet_id[1]
  tags = {
    Environment = var.prefix
    function    = "DB VM"
  }
}

module "web-vm" {
  source = "./modules/vm-linux"
  vm_name = "web-vm"
  location = var.location
  prefix = var.prefix
  resource_group_name = azurerm_resource_group.vm_rg.name
  subnet_id           = module.fs_vnet.subnet_id[1]
  tags = {
    Environment = var.prefix
    function    = "WEB VM"
  }
}

output "dbvm_pip" {
 value = module.db-vm.public_ip
}

output "webvm_pip" {
 value = module.web-vm.public_ip
}
