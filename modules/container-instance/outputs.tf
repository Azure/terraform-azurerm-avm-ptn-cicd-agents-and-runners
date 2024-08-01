output "resource_id" {
  description = "The ID of the container instance"
  value       = azurerm_container_group.alz.id
}

output "name" {
  description = "The name of the container instance"
  value       = azurerm_container_group.alz.name
}

output "resource" {
  description = "The container instance resource"
  value       = azurerm_container_group.alz
}
