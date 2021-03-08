variable "prefix" {
   description = "Prefix for the resource name"
   default = "full"
}

variable "location" {
   description = "Location for the Azure resource"
   default = "eastus"
}

variable "fs_cidr" {
   description = "CIDR of FS network"
   default = "10.10.0.0/16"
}
