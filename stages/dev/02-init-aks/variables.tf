variable "location" {
  type    = string
  default = "eastasia"
}

variable "resource_group_name" {
  type        = string
  description = "The hub resource group name"
  default     = "rg-0"
}

variable "vnet_id" {
  type = string
}

variable "eks_subnet_id" {
  type = string
}

variable "db_subnet_id" {
  type = string
}

variable "acr_name" {
  type    = string
  default = "jims-acr"
}

variable "cluster_name" {
  type    = string
  default = "development-jims"
}

variable "environment" {
  type = string
}