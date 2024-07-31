variable "use_private_networking" {
  type        = bool
  default     = true
  description = "Whether or not to use private networking for the container registry."
}

variable "postfix" {
  type        = string
  description = "A postfix used to build default names if no name has been supplied for a specific resource type."

  validation {
    condition     = length(var.postfix) <= 20
    error_message = "Variable 'name' must be less than 20 characters due to container app job naming restrictions. '${var.postfix}' is ${length(var.postfix)} characters."
  }
}

variable "version_control_system_type" {
  type        = string
  nullable    = false
  description = "The type of the version control system to deploy the agents too. Allowed values are 'azuredevops' or 'github'"
  validation {
    condition     = contains(["azuredevops", "github"], var.version_control_system_type)
    error_message = "cicd_system must be one of 'azuredevops' or 'github'"
  }
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
  type        = map(any)
  default     = {}
  description = "The map of tags to be applied to the resource"
}

variable "version_control_system_organization" {
  type        = string
  description = "The version control system organization to deploy the agents too."
}

variable "version_control_system_personal_access_token" {
  type        = string
  description = "The personal access token for the version control system."
  sensitive   = true
}

variable "version_control_system_repository" {
  type        = string
  description = "The version control system repository to deploy the agents too."
  default     = null
}

variable "version_control_system_pool_name" {
  type        = string
  description = "The name of the agent pool in the version control system."
  default     = null
}

variable "version_control_system_agent_name_prefix" {
  type        = string
  description = "The version control system agent name prefix."
  default     = null
}

variable "version_control_system_runner_scope" {
  type        = string
  description = "The scope of the runner. Must be `ent`, `org`, or `repo`. This is ignored for Azure DevOps."
  default     = "repo"
}

variable "version_control_system_runner_group" {
  type        = string
  description = "The runner group to add the runner to."
  default     = null
}

variable "version_control_system_enterprise" {
  type        = string
  description = "The enterprise name for the version control system."
  default     = null
}

variable "version_control_system_agent_target_queue_length" {
  type        = number
  default     = 1
  description = "The target value for the amound of pending jobs to scale on."
}
