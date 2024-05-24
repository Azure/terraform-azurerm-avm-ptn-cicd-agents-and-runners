variable "container_image_name" {
  type        = string
  description = "Fully qualified name of the Docker image the agents should run."
  nullable    = false
}

variable "azure_container_registries" {
  type = set(object({
    login_server = string
    identity     = string
  }))
  nullable    = true
  description = <<DESCRIPTION
A list of Azure Container Registries to link to the container app environment. Required values are:
- `login_server` - The login server url for the Azure Container Registry.
- `identity` - The id of the identity used to authenticate to the registry. For system managed identity, use 'System'.
DESCRIPTION
}

variable "name" {
  type        = string
  description = "Prefix used for naming the container app environment and container app jobs."

  validation {
    condition     = length(var.name) <= 20
    error_message = "Variable 'name' must be less than 20 characters due to container app job naming restrictions. '${var.name}' is ${length(var.name)} characters."
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the resources will be deployed."
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group where the resources will be deployed."
}

variable "container_app_environment_name" {
  type        = string
  description = "The name of the Container App Environment."
}

variable "container_app_job_runner_name" {
  type        = string
  description = "The name of the Container App runner job."
}

variable "key_vault_user_assigned_identity" {
  type        = string
  description = <<DESCRIPTION
The user assigned identity to use to authenticate with Key Vault.
Must be specified if multiple user assigned are specified in `managed_identities`.
DESCRIPTION
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
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
  description = "Managed identities to be created for the resource."
}

variable "max_execution_count" {
  type        = number
  description = "The maximum number of executions (ADO jobs) to spawn per polling interval."
}

variable "min_execution_count" {
  type        = number
  description = "The minimum number of executions (ADO jobs) to spawn per polling interval."
}

variable "pat_token_secret_url" {
  type        = string
  description = <<DESCRIPTION
The value of the personal access token the agents will use for authenticating to Azure DevOps.
One of 'pat_token_value' or 'pat_token_secret_url' must be specified.
DESCRIPTION
}

variable "pat_token_value" {
  type        = string
  description = <<DESCRIPTION
The value of the personal access token the agents will use for authenticating to Azure DevOps.
One of 'pat_token_value' or 'pat_token_secret_url' must be specified.
DESCRIPTION
}

variable "polling_interval_seconds" {
  type        = number
  description = "How often should the pipeline queue be checked for new events, in seconds."
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

variable "runner_agent_cpu" {
  type        = number
  description = "Required CPU in cores, e.g. 0.5"
}

variable "runner_agent_memory" {
  type        = string
  description = "Required memory, e.g. '250Mb'"
}

variable "runner_container_name" {
  type        = string
  description = "The name of the container for the runner Container Apps job."
}

variable "runner_replica_retry_limit" {
  type        = number
  description = "The number of times to retry the runner Container Apps job."
}

variable "runner_replica_timeout" {
  type        = number
  description = "The timeout in seconds for the runner Container Apps job."
}

variable "subnet_id" {
  type        = string
  description = "The subnet id to use for the Container App Environment."
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(any)
  description = "The map of tags to be applied to the resource"
}

variable "target_queue_length" {
  type        = number
  description = "The target value for the amound of pending jobs to scale on."
}

variable "tracing_tags_enabled" {
  type        = bool
  description = "Whether enable tracing tags that generated by BridgeCrew Yor."
  nullable    = false
}

variable "tracing_tags_prefix" {
  type        = string
  description = "Default prefix for generated tracing tags"
  nullable    = false
}

variable "virtual_network_id" {
  type        = string
  description = "The id of the virtual network to use for the Container App Environment."
  nullable    = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The id of the log analytics workspace to connect the container app agents to."
  nullable    = true
}