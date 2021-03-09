variable "prefix" {
   description = "Prefix for the resource name"
   default = "full"
}

variable "location" {
   description = "Location for the Azure resource"
   default = "eastus"
}

variable "fs_hub_cidr" {
   description = "CIDR of FS HUB network"
   default = "10.0.0.0/16"
}

variable "fs_spoke100_cidr" {
   description = "CIDR of FS SPOKE 1 network"
   default = "10.10.0.0/16"
}
