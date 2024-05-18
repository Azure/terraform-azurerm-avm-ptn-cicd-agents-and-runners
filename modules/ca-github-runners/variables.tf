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
}

variable "environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  description = "List of environment variables to pass to the container."
}

variable "pat_env_var_name" {
  type        = string
  nullable    = true
  default     = "GH_RUNNER_TOKEN"
  description = "Name of the PAT token environment variable. Defaults to 'GH_RUNNER_TOKEN'."
}