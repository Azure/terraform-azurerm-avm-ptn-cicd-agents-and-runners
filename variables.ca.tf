variable "container_app_environment_name" {
  type        = string
  default     = null
  description = "The name of the Container App Environment."
}

variable "container_app_job_placeholder_name" {
  type        = string
  default     = null
  description = "The name of the Container App placeholder job."
}

variable "container_app_job_runner_name" {
  type        = string
  default     = null
  description = "The name of the Container App runner job."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Terraform Id of the Log Analytics Workspace to connect to the Container App Environment."
}

variable "max_execution_count" {
  type        = number
  default     = 100
  description = "The maximum number of executions (ADO jobs) to spawn per polling interval."
}

variable "min_execution_count" {
  type        = number
  default     = 0
  description = "The minimum number of executions (ADO jobs) to spawn per polling interval."
}

variable "pat_token_secret_url" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The value of the personal access token the agents will use for authenticating to Azure DevOps.
One of 'pat_token_value' or 'pat_token_secret_url' must be specified.
DESCRIPTION
}

variable "pat_token_value" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The value of the personal access token the agents will use for authenticating to Azure DevOps.
One of 'pat_token_value' or 'pat_token_secret_url' must be specified.
DESCRIPTION
}

variable "placeholder_agent_name" {
  type        = string
  default     = "placeholder-agent"
  description = "The name of the agent that will appear in Azure DevOps for the placeholder agent."
}

variable "placeholder_container_name" {
  type        = string
  default     = "ado-agent-linux"
  description = "The name of the container for the placeholder Container Apps job."
}

variable "placeholder_replica_retry_limit" {
  type        = number
  default     = 0
  description = "The number of times to retry the placeholder Container Apps job."
}

variable "placeholder_replica_timeout" {
  type        = number
  default     = 300
  description = "The timeout in seconds for the placeholder Container Apps job."
}

variable "polling_interval_seconds" {
  type        = number
  default     = 30
  description = "How often should the pipeline queue be checked for new events, in seconds."
}

variable "runner_agent_cpu" {
  type        = number
  default     = 1.0
  description = "Required CPU in cores, e.g. 0.5"
}

variable "runner_agent_memory" {
  type        = string
  default     = "2Gi"
  description = "Required memory, e.g. '250Mb'"
}

variable "runner_container_name" {
  type        = string
  default     = "ado-agent-linux"
  description = "The name of the container for the runner Container Apps job."
}

variable "runner_replica_retry_limit" {
  type        = number
  default     = 3
  description = "The number of times to retry the runner Container Apps job."
}

variable "runner_replica_timeout" {
  type        = number
  default     = 1800
  description = "The timeout in seconds for the runner Container Apps job."
}

variable "target_queue_length" {
  type        = number
  default     = 1
  description = "The target value for the amound of pending jobs to scale on."
}

variable "log_analytics_workspace_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a log analytics workspace for the Container App Environment."
  nullable    = false
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "The name to give the deployed log analytics workspace."
  nullable    = true
}

variable "cicd_system" {
  type        = string
  default     = false
  description = "The name of the CI/CD system to deploy the agents too. Allowed values are 'AzureDevOps' or 'Github'"
  validation {
    condition     = contains(["azuredevops", "github"], lower(var.cicd_system))
    error_message = "cicd_system must be one of 'AzureDevOps' or 'Github'"
  }
}

variable "environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  nullable = true
  default = null
  description = "List of environment variables to pass to the container."
}

variable "pat_env_var_name" {
  type        = string
  nullable    = true
  default     = null
  description = <<DESCRIPTION
Name of the PAT token environment variable.
Defaults to 'AZP_TOKEN' when 'cicd_system' == 'AzureDevOps'
Defaults to 'GH_RUNNER_TOKEN' when 'cicd_system' == 'Github'
DESCRIPTION
}