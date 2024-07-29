output "resource_id" {
  description = "The ID of the container registry"
  value       = module.container_registry.resource_id
}

output "login_server" {
  description = "The login server of the container registry"
  value       = module.container_registry.resource.login_server
}

output "username" {
  description = "The username of the container registry"
  value       = module.container_registry.resource.admin_username
}

output "password" {
  description = "The password of the container registry"
  value       = module.container_registry.resource.admin_password
  sensitive = true
}

output "resource_name" {
    description = "The name of the container registry"
    value       = module.container_registry.name
}
