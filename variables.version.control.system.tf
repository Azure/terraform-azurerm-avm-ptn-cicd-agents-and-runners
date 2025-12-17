variable "version_control_system_organization" {
  type        = string
  description = "The version control system organization to deploy the agents too."
}

variable "version_control_system_type" {
  type        = string
  description = "The type of the version control system to deploy the agents too. Allowed values are 'azuredevops' or 'github'"
  nullable    = false

  validation {
    condition     = contains(local.valid_version_control_systems, var.version_control_system_type)
    error_message = "cicd_system must be one of 'azuredevops' or 'github'"
  }
}

variable "version_control_system_agent_name_prefix" {
  type        = string
  default     = null
  description = "The version control system agent name prefix."
}

variable "version_control_system_agent_target_queue_length" {
  type        = number
  default     = 1
  description = "The target value for the amound of pending jobs to scale on."
}

variable "version_control_system_authentication_method" {
  type        = string
  default     = "pat"
  description = "Authentication method. For Azure DevOps: 'pat' or 'uami' (requires Azure DevOps prerequisites - see README). For GitHub: 'pat' or 'github_app'"

  validation {
    condition = (
      var.version_control_system_type == "azuredevops" ? contains(["pat", "uami"], var.version_control_system_authentication_method) :
      contains(["pat", "github_app"], var.version_control_system_authentication_method)
    )
    error_message = "For Azure DevOps, authentication_method must be 'pat' or 'uami'. For GitHub, authentication_method must be 'pat' or 'github_app'."
  }
}

variable "version_control_system_enterprise" {
  type        = string
  default     = null
  description = "The enterprise name for the version control system."
}

variable "version_control_system_github_application_id" {
  type        = string
  default     = ""
  description = "The application ID for the GitHub App authentication method."

  validation {
    condition = (
      var.version_control_system_authentication_method == "github_app" ? length(var.version_control_system_github_application_id) > 0 : true
    )
    error_message = "Variable version_control_system_github_application_id must be defined when version_control_system_authentication_method is github_app."
  }
}

variable "version_control_system_github_application_installation_id" {
  type        = string
  default     = ""
  description = "The installation ID for the GitHub App authentication method."

  validation {
    condition = (
      var.version_control_system_authentication_method == "github_app" ? length(var.version_control_system_github_application_installation_id) > 0 : true
    )
    error_message = "Variable version_control_system_github_application_installation_id must be defined when version_control_system_authentication_method is github_app."
  }
}

variable "version_control_system_github_application_key" {
  type        = string
  default     = null
  description = "The application key for the GitHub App authentication method."
  sensitive   = true

  validation {
    condition = (
      var.version_control_system_authentication_method == "github_app" ? var.version_control_system_github_application_key != "" && var.version_control_system_github_application_key != null : true
    )
    error_message = "Variable version_control_system_github_application_key must be defined when version_control_system_authentication_method is github_app."
  }
}

variable "version_control_system_personal_access_token" {
  type        = string
  default     = null
  description = "The personal access token for the version control system. Required when authentication_method is 'pat'."
  sensitive   = true

  validation {
    condition = (
      var.version_control_system_authentication_method == "pat" ? var.version_control_system_personal_access_token != "" && var.version_control_system_personal_access_token != null : true
    )
    error_message = "Variable version_control_system_personal_access_token must be defined when version_control_system_authentication_method is pat."
  }
}

variable "version_control_system_placeholder_agent_name" {
  type        = string
  default     = null
  description = "The version control system placeholder agent name."
}

variable "version_control_system_pool_name" {
  type        = string
  default     = null
  description = "The name of the agent pool in the version control system."
}

variable "version_control_system_repository" {
  type        = string
  default     = null
  description = "The version control system repository to deploy the agents too."
}

variable "version_control_system_runner_group" {
  type        = string
  default     = null
  description = "The runner group to add the runner to."
}

variable "version_control_system_runner_scope" {
  type        = string
  default     = "repo"
  description = "The scope of the runner. Must be `ent`, `org`, or `repo`. This is ignored for Azure DevOps."
}
