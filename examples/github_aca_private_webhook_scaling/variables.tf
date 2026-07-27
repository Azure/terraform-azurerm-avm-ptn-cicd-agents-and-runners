variable "github_application_id" {
  type        = string
  description = "The GitHub App ID used for runner registration."
}

variable "github_application_installation_id" {
  type        = string
  description = "The GitHub App installation ID for the organization."
}

variable "github_application_key" {
  type        = string
  description = "The GitHub App private key (PEM)."
  sensitive   = true
}

variable "github_organization_name" {
  type        = string
  description = "The name of the GitHub organization."
}
