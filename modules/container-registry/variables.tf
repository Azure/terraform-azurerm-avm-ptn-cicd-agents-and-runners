variable "container_compute_identity_principal_id" {
  type        = string
  description = "The principal id of the managed identity used by the container compute to pull images from the container registry"
}

variable "enable_telemetry" {
  type        = bool
  description = "Whether to enable telemetry for the container registry"
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the container registry"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the container registry"
}

variable "use_private_networking" {
  type        = bool
  description = "Whether to use private networking for the container registry"
}

variable "images" {
  type = map(object({
    task_name            = string
    dockerfile_path      = string
    context_path         = string
    context_access_token = optional(string, "a") # This `a` is a dummy value because the context_access_token should not be required in the provider
    image_names          = list(string)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of objects that define the images to build in the container registry. The key of the map is the name of the image and the value is an object with the following attributes:

- `task_name` - The name of the task to create for building the image (e.g. `image-build-task`)
- `dockerfile_path` - The path to the Dockerfile to use for building the image (e.g. `dockerfile`)
- `context_path` - The path to the context of the Dockerfile in three sections `<repository-url>#<repository-commit>:<repository-folder-path>` (e.g. https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners#8ff4b85:container-images/azure-devops-agent)
- `context_access_token` - The access token to use for accessing the context. Supply a PAT if targetting a private repository.
- `image_names` - A list of the names of the images to build (e.g. `["image-name:tag"]`)
DESCRIPTION
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "The id of the private DNS zone to create for the container registry. Only required if `container_registry_private_dns_zone_creation_enabled` is `false` and you are not using policy to update the DNS zone."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "The id of the subnet to use for the private endpoint"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "use_zone_redundancy" {
  type        = bool
  default     = true
  description = "Enable zone redundancy for the deployment"

  validation {
    condition     = !(var.use_zone_redundancy == true && var.use_private_networking == false)
    error_message = "Zone redundancy requires private networking to be enabled. When use_zone_redundancy is true, use_private_networking must also be true because infrastructure_subnet_id is required for zone redundant deployments."
  }
}
