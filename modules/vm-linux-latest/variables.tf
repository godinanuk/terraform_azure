variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "vm_name" {
   description = "Name of VM"
}

variable "resource_group_name" {
    description = "vm resource group name"
}

variable "subnet_id" {
  description = "Subnet ID associated with VM network interface card"
}

variable "tags" {
  description = "Tags for the resource"
}
