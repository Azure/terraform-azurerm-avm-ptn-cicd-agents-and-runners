variable "github_keda_metadata" {
  type = object({
    githubAPIURL              = optional(string, "https://api.github.com")
    owner                     = string
    runnerScope               = string
    repos                     = optional(string)
    labels                    = optional(set(string))
    targetWorkflowQueueLength = optional(string, "1")
    applicationID             = optional(string)
    installationID            = optional(string)
  })
  nullable = true
  default = null
  description = <<DESCRIPTION
Metadata for the Keda Github Runner Scaler
https://keda.sh/docs/2.13/scalers/github-runner/
DESCRIPTION
}