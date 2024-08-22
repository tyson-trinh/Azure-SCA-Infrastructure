resource "azurerm_container_registry" "this" {
  location            = var.location
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  sku                 = "Premium"

  retention_policy {
    days    = 7
    enabled = true
  }
}

module "aks" {
  source              = "../../../modules/terraform-azurerm-aks"
  prefix              = var.environment
  cluster_name        = var.cluster_name
  resource_group_name = var.resource_group_name
  #   kubernetes_version        = "1.30"
  automatic_channel_upgrade = "stable"
  agents_availability_zones = ["1"]
  agents_count              = null
  agents_max_count          = 2
  agents_max_pods           = 100
  agents_min_count          = 1
  agents_pool_name          = "development"
  agents_size               = "Standard_D4as_v5"
  agents_pool_linux_os_configs = [
    {
      transparent_huge_page_enabled = "always"
      sysctl_configs = [
        {
          fs_aio_max_nr               = 65536
          fs_file_max                 = 100000
          fs_inotify_max_user_watches = 1000000
        }
      ]
    }
  ]
  agents_type          = "VirtualMachineScaleSets"
  azure_policy_enabled = false
  confidential_computing = {
    sgx_quote_helper_enabled = true
  }
  enable_auto_scaling               = true
  enable_host_encryption            = false
  local_account_disabled            = true
  log_analytics_workspace_enabled   = false
  net_profile_dns_service_ip        = "172.0.0.10"
  net_profile_service_cidr          = "172.0.0.0/16"
  network_plugin                    = "azure"
  network_policy                    = "calico"
  node_os_channel_upgrade           = "NodeImage"
  os_disk_size_gb                   = 30
  private_cluster_enabled           = false
  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true
  rbac_aad_azure_rbac_enabled       = true
  sku_tier                          = "Free"
  vnet_subnet_id                    = var.eks_subnet_id

  attached_acr_id_map = {
    this = azurerm_container_registry.this.id
  }

  agents_labels = {
    "environment" : "development"
  }
  agents_tags = {
    "environment" : "development"
  }
}