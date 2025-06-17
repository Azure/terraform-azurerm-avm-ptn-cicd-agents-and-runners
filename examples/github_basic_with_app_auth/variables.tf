variable "github_application_id" {
  type        = string
  description = "The application ID used for the GitHub App authentication method."
}

variable "github_application_installation_id" {
  type        = string
  description = "The Installation ID used for the GitHub App authentication method."
}

variable "github_application_key" {
  type        = string
  description = "The application key used for the GitHub App authentication method. Import key file as environment variable: $env:TF_VAR_github_application_key = Get-Content path\to\\[private_key_name].pem -Raw"
  sensitive   = true
}

variable "github_organization_name" {
  type        = string
  description = "GitHub Organisation Name"
}

variable "github_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to GitHub."
  sensitive   = true
}
