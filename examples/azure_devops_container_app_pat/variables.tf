variable "azure_devops_agents_personal_access_token" {
  type        = string
  description = "Personal access token for Azure DevOps self-hosted agents (the token requires the 'Agent Pools - Read & Manage' scope and should have the maximum expiry)."
  sensitive   = true
}

variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "Personal Access Token for Azure DevOps authentication. Required scopes: Agent Pools (Read & Manage), Build (Read & Execute), Code (Read & Write), Project and Team (Read & Write)"
  sensitive   = true
}
