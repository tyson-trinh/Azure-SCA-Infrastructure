locals {
  vnet_id = module.vnet.vnet_id
  eks_subnet_id = lookup(module.vnet.vnet_subnets_name_id, "subnet1")
  db_subnet_id = lookup(module.vnet.vnet_subnets_name_id, "subnet2")
}

module "vnet" {
  source              = "../../../modules/terraform-azurerm-vnet"
  vnet_name           = var.vnet_name
  resource_group_name = var.resource_group_name
  use_for_each        = var.use_for_each
  address_space = ["10.0.0.0/16"]
  subnet_prefixes = ["10.0.0.0/22", "10.0.4.0/24"]
  subnet_names = ["subnet1", "subnet2"]
  vnet_location       = var.location

  nsg_ids = {
    subnet1 = azurerm_network_security_group.this.id
  }

  subnet_service_endpoints = {
    subnet2 = ["Microsoft.Storage", "Microsoft.Sql"],
  }

  subnet_delegation = {
    subnet2 = {
      "Microsoft.Sql.managedInstances" = {
        service_name = "Microsoft.Sql/managedInstances"
        service_actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
        ]
      }
    }
  }

  route_tables_ids = {
    subnet1 = azurerm_route_table.this.id
  }

  tags = {
    environment = var.environment
  }

  #   subnet_enforce_private_link_endpoint_network_policies = {
  #     subnet2 = true
  #   }
  #
  #   subnet_enforce_private_link_service_network_policies = {
  #     subnet3 = true
  #   }
}

resource "azurerm_network_security_group" "this" {
  location            = var.location
  name                = "${var.environment}-default-nsg"
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_route_table" "this" {
  location            = var.location
  name                = "${var.environment}-default-rt"
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "nat_gateway_ip" {
  name                = "svidify-${var.environment}-public-ip-nat"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_attach_ip" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "attach_nat_gateway_with_eks" {
  subnet_id      = local.eks_subnet_id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

# resource "tls_private_key" "ssh" {
#   algorithm = "RSA"
#   rsa_bits  = "4096"
# }
#
# resource "local_file" "ssh_private_key" {
#   filename = "${path.module}/key.pem"
#   content  = tls_private_key.ssh.private_key_pem
#   file_permission = "0400"
# }
#
# resource "azurerm_public_ip" "my_public_ip_vm" {
#   name                = "public-ip-vm"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }
#
# resource "azurerm_network_interface" "my_vm_nic" {
#   name                = "nic-1"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#
#   ip_configuration {
#     name                          = "my_nic_configuration"
#     subnet_id                     = local.eks_subnet_id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.my_public_ip_vm.id
#   }
# }
#
# resource "azurerm_network_security_group" "my_terraform_nsg" {
#   name                = "checking-nsg"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#
#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }
#
# resource "azurerm_network_interface_security_group_association" "attach_vm_with_nsg" {
#   network_interface_id      = azurerm_network_interface.my_vm_nic.id
#   network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
# }
#
# resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
#   name                  = "vm-1"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   network_interface_ids = [azurerm_network_interface.my_vm_nic.id]
#   size                  = "Standard_DS1_v2"
#
#   os_disk {
#     name                 = "myOsDisk"
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#     disk_size_gb = "30"
#   }
#
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }
#
#   admin_username = "jims"
#
#   admin_ssh_key {
#     username   = "jims"
#     public_key = tls_private_key.ssh.public_key_openssh
#   }
#
# #   boot_diagnostics {
# #     storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
# #   }
# }
#
# output "checking-vm" {
#   value = azurerm_public_ip.my_public_ip_vm.ip_address
# }