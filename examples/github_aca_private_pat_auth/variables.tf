variable "github_organization_name" {
  type        = string
  description = "GitHub Organisation Name"
}

variable "github_runners_personal_access_token" {
  type        = string
  description = "Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire)."
  sensitive   = true
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
