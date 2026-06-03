variable "version_control_system_organization" {
  type        = string
  description = "The version control system organization to deploy the agents too."
}

variable "version_control_system_type" {
  type        = string
  description = "The type of the version control system to deploy the agents too. Allowed values are 'azuredevops' or 'github'"
  nullable    = false

  validation {
    condition     = contains(local.valid_version_control_systems, var.version_control_system_type)
    error_message = "cicd_system must be one of 'azuredevops' or 'github'"
  }
}

variable "version_control_system_agent_name_prefix" {
  type        = string
  default     = null
  description = "The version control system agent name prefix."
}

variable "version_control_system_agent_target_queue_length" {
  type        = number
  default     = 1
  description = "The target value for the amound of pending jobs to scale on."
}

variable "version_control_system_authentication_method" {
  type        = string
  default     = null
  description = "Authentication method. For Azure DevOps: 'pat' or 'uami' (requires Azure DevOps prerequisites - see README). For GitHub: 'pat' or 'github_app'. If null (the default), Azure DevOps falls back to 'uami' and GitHub falls back to 'github_app'."

  validation {
    condition = (
      var.version_control_system_authentication_method == null ? true :
      var.version_control_system_type == "azuredevops" ? contains(["pat", "uami"], var.version_control_system_authentication_method) :
      contains(["pat", "github_app"], var.version_control_system_authentication_method)
    )
    error_message = "For Azure DevOps, authentication_method must be 'pat' or 'uami'. For GitHub, authentication_method must be 'pat' or 'github_app'. Leave null to use the default for the chosen version_control_system_type."
  }
}

variable "version_control_system_enterprise" {
  type        = string
  default     = null
  description = "The enterprise name for the version control system."
}

variable "version_control_system_github_application_id" {
  type        = string
  default     = ""
  description = "The application ID for the GitHub App authentication method."

  validation {
    condition = (
      coalesce(var.version_control_system_authentication_method, var.version_control_system_type == "azuredevops" ? "uami" : "github_app") == "github_app" ? length(var.version_control_system_github_application_id) > 0 : true
    )
    error_message = "Variable version_control_system_github_application_id must be defined when version_control_system_authentication_method is github_app."
  }
}

variable "version_control_system_github_application_installation_id" {
  type        = string
  default     = ""
  description = "The installation ID for the GitHub App authentication method."

  validation {
    condition = (
      coalesce(var.version_control_system_authentication_method, var.version_control_system_type == "azuredevops" ? "uami" : "github_app") == "github_app" ? length(var.version_control_system_github_application_installation_id) > 0 : true
    )
    error_message = "Variable version_control_system_github_application_installation_id must be defined when version_control_system_authentication_method is github_app."
  }
}

variable "version_control_system_github_application_key" {
  type        = string
  default     = null
  description = "The application key for the GitHub App authentication method."
  sensitive   = true

  validation {
    condition = (
      coalesce(var.version_control_system_authentication_method, var.version_control_system_type == "azuredevops" ? "uami" : "github_app") == "github_app" ? var.version_control_system_github_application_key != "" && var.version_control_system_github_application_key != null : true
    )
    error_message = "Variable version_control_system_github_application_key must be defined when version_control_system_authentication_method is github_app."
  }
}

variable "version_control_system_personal_access_token" {
  type        = string
  default     = null
  description = "The personal access token for the version control system. Required when authentication_method is 'pat'."
  sensitive   = true

  validation {
    condition = (
      coalesce(var.version_control_system_authentication_method, var.version_control_system_type == "azuredevops" ? "uami" : "github_app") == "pat" ? var.version_control_system_personal_access_token != "" && var.version_control_system_personal_access_token != null : true
    )
    error_message = "Variable version_control_system_personal_access_token must be defined when version_control_system_authentication_method is pat."
  }
}

variable "version_control_system_placeholder_agent_name" {
  type        = string
  default     = null
  description = "The version control system placeholder agent name."
}

variable "version_control_system_pool_name" {
  type        = string
  default     = null
  description = "The name of the agent pool in the version control system."
}

variable "version_control_system_repository" {
  type        = string
  default     = null
  description = "The version control system repository to deploy the agents too."
}

variable "version_control_system_runner_group" {
  type        = string
  default     = null
  description = "The runner group to add the runner to."
}

variable "version_control_system_runner_scope" {
  type        = string
  default     = "repo"
  description = "The scope of the runner. Must be `ent`, `org`, or `repo`. This is ignored for Azure DevOps."
}

variable "version_control_system_runner_labels" {
  type        = list(string)
  default     = []
  description = <<DESCRIPTION
Custom labels to register the runner with. **GitHub only.** Azure DevOps uses pool/demands, not labels.

When non-empty, the labels are wired into two places that must always stay in sync:

1. The runner container's `LABELS` env var, which becomes `config.sh --labels <csv>` at registration time.
2. The KEDA `github-runner` scaler's `labels` metadata, so the scaler only triggers on queued jobs that request a matching label set.

In webhook scaling mode (`webhook_scaling_enabled = true`) the KEDA scaler is `azure-queue` and ignores GitHub labels; the labels still apply to runner registration, and your webhook receiver is responsible for filtering jobs by label before enqueueing.

Set a unique label (e.g. `["self-hosted","linux","my-pool"]`) when you operate multiple runner pools in the same org to prevent cross-pool job pickup.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for l in var.version_control_system_runner_labels :
      length(trimspace(l)) > 0 && !can(regex(",", l)) && length(l) <= 100
    ])
    error_message = "Each label must be non-empty, contain no commas, and be <=100 chars (LABELS and KEDA `labels` are comma-separated lists)."
  }

  validation {
    condition     = length(var.version_control_system_runner_labels) == length(distinct(var.version_control_system_runner_labels))
    error_message = "version_control_system_runner_labels must not contain duplicates."
  }

  validation {
    condition = (
      var.version_control_system_type == "azuredevops"
      ? length(var.version_control_system_runner_labels) == 0
      : true
    )
    error_message = "version_control_system_runner_labels is GitHub-only. Azure DevOps uses pool name and demands."
  }
}

variable "version_control_system_runner_no_default_labels" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
Disable the default `self-hosted`, `linux`, `<arch>` labels the GitHub runner adds during registration. **GitHub only.**

Forwards `NO_DEFAULT_LABELS=true` to the runner container (applies `--no-default-labels` to `config.sh`) and sets `noDefaultLabels = "true"` on the KEDA `github-runner` scaler so scaling decisions also ignore default labels.

Only set this when you provide an explicit, non-empty `version_control_system_runner_labels` set - a runner with no labels at all cannot be targeted by any workflow.
DESCRIPTION
  nullable    = false

  validation {
    condition = (
      var.version_control_system_runner_no_default_labels
      ? length(var.version_control_system_runner_labels) > 0
      : true
    )
    error_message = "version_control_system_runner_no_default_labels = true requires at least one entry in version_control_system_runner_labels (otherwise the runner would have no labels and be unreachable)."
  }

  validation {
    condition = (
      var.version_control_system_type == "azuredevops"
      ? var.version_control_system_runner_no_default_labels == false
      : true
    )
    error_message = "version_control_system_runner_no_default_labels is GitHub-only."
  }
}

variable "version_control_system_keda_enable_etags" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
When true, sets `enableEtags = "true"` on the KEDA `github-runner` scaler so the scaler uses HTTP ETag conditional requests when polling the GitHub API, reducing API rate limit consumption when nothing has changed since the previous poll. Requires KEDA >= 2.17. **GitHub only.**
DESCRIPTION
  nullable    = false

  validation {
    condition = (
      var.version_control_system_type == "azuredevops"
      ? var.version_control_system_keda_enable_etags == false
      : true
    )
    error_message = "version_control_system_keda_enable_etags is GitHub-only."
  }
}

variable "version_control_system_github_url" {
  type        = string
  default     = "github.com"
  description = <<DESCRIPTION
The base URL for GitHub. Use the default `github.com` for standard GitHub Enterprise Cloud,
or `<subdomain>.ghe.com` for GitHub Enterprise Cloud with data residency. Ignored for Azure DevOps.

When set to a non-`github.com` value the module:
- emits `GITHUB_HOST=<value>` into the runner container environment so `config.sh` registers against the right host;
- sets `githubApiURL = https://api.<value>` on the KEDA `github-runner` scaler so it polls the right API.
DESCRIPTION
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.version_control_system_github_url))
    error_message = "version_control_system_github_url must be a valid domain name (e.g. `github.com` or `mycompany.ghe.com`). Do not include the protocol prefix."
  }
}
