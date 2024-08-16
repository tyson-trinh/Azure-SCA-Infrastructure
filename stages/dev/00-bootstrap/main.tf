resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_storage_account" "this" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.location
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
}

resource "azurerm_storage_container" "bootstrap_state" {
  name                  = "bootstraptfstate"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "network_state" {
  name                  = "networktfstate"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "init_state" {
  name                  = "inittfstate"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "init_workload" {
  name                  = "initworkload"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}