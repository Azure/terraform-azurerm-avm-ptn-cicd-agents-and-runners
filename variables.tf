variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "postfix" {
  type        = string
  description = "A postfix used to build default names if no name has been supplied for a specific resource type."

  validation {
    condition     = length(var.postfix) <= 20
    error_message = "Variable 'name' must be less than 20 characters due to container app job naming restrictions. '${var.postfix}' is ${length(var.postfix)} characters."
  }
}

variable "compute_types" {
  type        = set(string)
  default     = ["azure_container_app"]
  description = "The types of compute to use. Allowed values are 'azure_container_app' and 'azure_container_instance'."

  validation {
    condition     = alltrue([for compute_type in var.compute_types : contains(["azure_container_app", "azure_container_instance"], compute_type)])
    error_message = "compute_types must be a combination of 'azure_container_app' and 'azure_container_instance'"
  }
}

variable "delays" {
  type = object({
    delay_after_container_image_build              = optional(number, 60)
    delay_after_container_app_environment_creation = optional(number, 120)
  })
  default     = {}
  description = "Delays (in seconds) to apply to the module operations."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
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

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "use_private_networking" {
  type        = bool
  default     = true
  description = "Whether or not to use private networking for the container registry."
}
