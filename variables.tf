variable "container_image_name" {
  type        = string
  description = "Fully qualified name of the Docker image the agents should run."
  nullable    = false
}

variable "name" {
  type        = string
  description = "Prefix used for naming the container app environment and container app jobs."

  validation {
    condition     = length(var.name) <= 20
    error_message = "Variable 'name' must be less than 20 characters due to container app job naming restrictions. '${var.name}' is ${length(var.name)} characters."
  }
}

variable "azure_container_registries" {
  type = set(object({
    login_server = string
    identity     = string
  }))
  default     = null
  description = <<DESCRIPTION
A list of Azure Container Registries to link to the container app environment. Required values are:
- `login_server` - The login server url for the Azure Container Registry.
- `identity` - The id of the identity used to authenticate to the registry. For system managed identity, use 'System'.
DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "key_vault_user_assigned_identity" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The user assigned identity to use to authenticate with Key Vault.
Must be specified if multiple user assigned are specified in `managed_identities`.
DESCRIPTION
}

variable "location" {
  type        = string
  default     = null
  description = "Azure region where the resource should be deployed. Must be specified if `resource_group_creation_enabled == true`."
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
  default     = {}
  description = "The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."
  nullable    = false

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identities to be created for the resource."
}

variable "resource_group_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a resource group."
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "The resource group where the resources will be deployed. Must be specified if `resource_group_creation_enabled == false`"
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
}

variable "subnet_address_prefix" {
  type        = string
  default     = ""
  description = "The address prefix for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
  nullable    = false
}

variable "subnet_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a subnet for the Container App Environment."
  nullable    = false
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "The ID of a pre-existing subnet to use for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
  nullable    = false
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = "The subnet name for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(any)
  default     = {}
  description = "The map of tags to be applied to the resource"
}

variable "tracing_tags_enabled" {
  type        = bool
  default     = false
  description = "Whether enable tracing tags that generated by BridgeCrew Yor."
  nullable    = false
}

variable "tracing_tags_prefix" {
  type        = string
  default     = "avm_"
  description = "Default prefix for generated tracing tags"
  nullable    = false
}

variable "virtual_network_address_space" {
  type        = string
  default     = ""
  description = "The address range for the Container App Environment virtual network. Either virtual_network_id or virtual_network_name and virtual_network_address_range must be specified."
  nullable    = false
}

variable "virtual_network_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a virtual network for the Container App Environment."
  nullable    = false
}

variable "virtual_network_id" {
  type        = string
  default     = ""
  description = "The ID of a pre-existing virtual network to use for the Container App Environment. Either virtual_network_id or virtual_network_name and virtual_network_address_range must be specified."
  nullable    = false
}

variable "virtual_network_name" {
  type        = string
  default     = ""
  description = "The virtual network name for the Container App Environment. Either virtual_network_id or virtual_network_name and virtual_network_address_range must be specified."
  nullable    = false
}

variable "virtual_network_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the Virtual Network's Resource Group. Must be specified if `virtual_network_creation_enabled` == `false`"
  nullable    = false
}
