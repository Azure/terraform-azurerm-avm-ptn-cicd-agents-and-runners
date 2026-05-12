variable "azure_devops_agents_personal_access_token" {
  type        = string
  description = "Personal access token for Azure DevOps self-hosted agents (the token requires the 'Agent Pools - Read & Manage' scope and should have the maximum expiry)."
  sensitive   = true
}

variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}
