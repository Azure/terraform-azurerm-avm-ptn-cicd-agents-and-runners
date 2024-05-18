variable "azp_pool_name" {
  type        = string
  description = "Name of the pool that agents should register against in Azure DevOps."
}

variable "azp_url" {
  type        = string
  description = "URL for the Azure DevOps project."
}

variable "container_app_job_placeholder_name" {
  type        = string
  description = "The name of the Container App placeholder job."
}

variable "placeholder_agent_name" {
  type        = string
  description = "The name of the agent that will appear in Azure DevOps for the placeholder agent."
}

variable "placeholder_container_name" {
  type        = string
  description = "The name of the container for the placeholder Container Apps job."
}

variable "placeholder_replica_retry_limit" {
  type        = number
  description = "The number of times to retry the placeholder Container Apps job."
}

variable "placeholder_replica_timeout" {
  type        = number
  description = "The timeout in seconds for the placeholder Container Apps job."
}

variable "pat_env_var_name" {
  type        = string
  nullable    = true
  default     = "AZP_TOKEN"
  description = "Name of the PAT token environment variable. Defaults to 'AZP_TOKEN'."
}