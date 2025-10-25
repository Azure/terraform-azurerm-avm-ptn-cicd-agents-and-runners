variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "The personal access token used for creating Azure DevOps resources (project, agent pool, repository, etc.). This is different from the agent authentication which uses UAMI."
  sensitive   = true
}
