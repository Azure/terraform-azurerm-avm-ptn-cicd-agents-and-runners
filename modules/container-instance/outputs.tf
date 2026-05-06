output "name" {
  description = "The name of the container instance"
  value       = azapi_resource.container_group.name
}

output "resource" {
  description = "The container instance resource"
  value       = azapi_resource.container_group
}

output "resource_id" {
  description = "The ID of the container instance"
  value       = azapi_resource.container_group.id
}
