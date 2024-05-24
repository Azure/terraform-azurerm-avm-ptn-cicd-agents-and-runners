variable "ado_organization_url" {
  type        = string
  description = "Azure DevOps Organisation URL"
}

variable "personal_access_token" {
  type        = string
  description = "The personal access token used for agent authentication to Azure DevOps."
  sensitive   = true
}
