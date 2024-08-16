locals {
  tfvars = {
    location            = var.location
    resource_group_name = var.resource_group_name
    vnet_id             = module.vnet.vnet_id
    eks_subnet_id       = lookup(module.vnet.vnet_subnets_name_id, "subnet1")
    db_subnet_id        = lookup(module.vnet.vnet_subnets_name_id, "subnet2")
  }
}

resource "local_file" "auto_init_aks_tfvars" {
  file_permission = "0644"
  filename        = "${path.module}/../02-init-aks/auto-init-aks.auto.tfvars.json"
  content         = jsonencode(local.tfvars)
}
