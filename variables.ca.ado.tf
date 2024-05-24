variable "azp_pool_name" {
  type        = string
  description = "Name of the pool that agents should register against in Azure DevOps."
  nullable    = true
  default     = null
}

variable "azp_url" {
  type        = string
  description = "URL for the Azure DevOps project."
  nullable    = true
  default     = null
}