output "login_server" {
  description = "The login server of the container registry"
  value       = module.container_registry.resource.login_server
}

output "name" {
  description = "The name of the container registry"
  value       = module.container_registry.name
}

output "resource_id" {
  description = "The ID of the container registry"
  value       = module.container_registry.resource_id
}
