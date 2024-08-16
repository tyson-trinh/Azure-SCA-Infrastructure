variable "location" {
  type = string
  description = "The location of resource on AZ"
  default = "switzerlandnorth"
}

variable "resource_group_name" {
  type = string
  description = "The Resource Group"
  default = "svidify-jims-dev"
}

variable "organization_name" {
  type = string
  description = "The name of organization"
  default = "svidify"
}

variable "storage_account_name" {
  type = string
  default = "development"
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}