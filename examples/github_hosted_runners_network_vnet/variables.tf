variable "github_hosted_runners_business_id" {
  type        = string
  description = "GitHub Enterprise business ID used for hosted runners Azure private networking."
}

variable "github_organization_name" {
  type        = string
  description = "GitHub organization name."
}

variable "github_runners_personal_access_token" {
  type        = string
  description = "Personal access token for GitHub (required by the module interface when using PAT authentication)."
  sensitive   = true
}
