output "fw_private_ip" {
  value = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

output "public_fw_Ip" {
  value = azurerm_public_ip.firewall_public_ip.ip_address
}

output "fw_name" {
  value = azurerm_firewall.fw.name
}