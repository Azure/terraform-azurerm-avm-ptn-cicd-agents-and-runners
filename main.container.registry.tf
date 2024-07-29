module "container_registry" {
    count = var.create_container_registry ? 1 : 0
    source  = "./modules/container-registry"
    
    location            = var.location
    name                = local.container_registry_name
    resource_group_name = local.resource_group_name
    enable_telemetry = var.enable_telemetry
    container_compute_identity_principal_id = local.user_assigned_managed_identity_principal_id
    use_private_networking = var.use_private_networking
    tags = var.tags

    images = local.container_images
}