variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "The personal access token used by the azuredevops Terraform provider to manage Azure DevOps resources."
  sensitive   = true
}
