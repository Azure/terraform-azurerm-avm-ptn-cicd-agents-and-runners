variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps organization name (without the dev.azure.com prefix)."
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "Personal access token used by the Azure DevOps provider to create example resources."
  sensitive   = true
}
