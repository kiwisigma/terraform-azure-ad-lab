output "resource_group_id" {
  description = "The ID of the created resource group."
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "The Azure region of the resource group."
  value       = azurerm_resource_group.main.location
}

output "vm_public_ip" {
  description = "Public IP of the Domain Controller VM (RDP target)."
  value       = azurerm_public_ip.main.ip_address
}

output "rdp_command" {
  description = "How to connect from Windows."
  value       = "mstsc /v:${azurerm_public_ip.main.ip_address}  (user: ${var.admin_username})"
}
