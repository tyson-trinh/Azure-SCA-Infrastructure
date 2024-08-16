variable "location" {
  type = string
  default = "eastasia"
}

variable "resource_group_name" {
  type = string
  description = "The hub resource group name"
  default = "hub-rg-0"
}

variable "vnet_name" {
  type = string
  default = "dev-svidify-vnet"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "use_for_each" {
  type    = bool
  default = true
}