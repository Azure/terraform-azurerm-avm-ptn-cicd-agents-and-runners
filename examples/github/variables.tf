variable "ado_organization_url" {
  type        = string
  description = "Azure DevOps Organisation URL"
}

variable "personal_access_token" {
  type        = string
  description = "The personal access token used for agent authentication to Azure DevOps."
  sensitive   = true
}

variable "container_image_name" {
  type        = string
  default     = "azure-pipelines:latest"
  description = "Name of the container image to build and push to the container registry"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
