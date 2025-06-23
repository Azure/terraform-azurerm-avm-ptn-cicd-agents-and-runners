variable "github_organization_name" {
  type        = string
  description = "GitHub Organisation Name"
}

variable "github_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to GitHub."
  sensitive   = true
}

variable "github_runners_personal_access_token" {
  type        = string
  description = "Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire)."
  sensitive   = true
}
