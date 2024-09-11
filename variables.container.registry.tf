
variable "container_registry_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a container registry."
}

variable "container_registry_name" {
  type        = string
  default     = null
  description = "The name of the container registry. Only required if `container_registry_creation_enabled` is `true`."
}

variable "custom_container_registry_login_server" {
  type        = string
  description = "The login server of the container registry to use if `container_registry_creation_enabled` is `false`."
  default     = null
}

variable "custom_container_registry_username" {
  type        = string
  description = "The username of the container registry to use if `container_registry_creation_enabled` is `false`."
  default     = null
}

variable "custom_container_registry_password" {
  type        = string
  description = "The password of the container registry to use if `container_registry_creation_enabled` is `false`."
  default     = null
  sensitive   = true
}

variable "use_default_container_image" {
  type        = bool
  default     = true
  description = "Whether or not to use the default container image provided by the module."
}

variable "custom_container_registry_images" {
  type = map(object({
    task_name            = string
    dockerfile_path      = string
    context_path         = string
    context_access_token = optional(string, "a") # This `a` is a dummy value because the context_access_token should not be required in the provider
    image_names          = list(string)
  }))
  default     = null
  description = <<DESCRIPTION
The images to build and push to the container registry. This is only relevant if `container_registry_creation_enabled` is `true` and `use_default_container_image` is set to `false`.

- task_name: The name of the task to create for building the image (e.g. `image-build-task`)
- dockerfile_path: The path to the Dockerfile to use for building the image (e.g. `dockerfile`)
- context_path: The path to the context of the Dockerfile in three sections `<repository-url>#<repository-commit>:<repository-folder-path>` (e.g. https://github.com/Azure/avm-container-images-cicd-agents-and-runners#bc4087f:azure-devops-agent)
- context_access_token: The access token to use for accessing the context. Supply a PAT if targetting a private repository.
- image_names: A list of the names of the images to build (e.g. `["image-name:tag"]`)

DESCRIPTION
}

variable "default_image_repository_url" {
  type        = string
  description = "The default image repository URL to use if no custom image is provided."
  default     = "https://github.com/Azure/avm-container-images-cicd-agents-and-runners"
}

variable "default_image_repository_commit" {
  type        = string
  description = "The default image repository commit to use if no custom image is provided."
  default     = "bc4087f"
}

variable "default_image_repository_folder_paths" {
  type        = map(string)
  description = "The default image repository folder path to use if no custom image is provided."
  default = {
    azuredevops-container-app      = "azure-devops-agent-aca"
    github-container-app           = "github-runner-aca"
    azuredevops-container-instance = "azure-devops-agent-aci"
    github-container-instance      = "github-runner-aci"
  }
}

variable "default_image_registry_dockerfile_path" {
  type        = string
  description = "The default image registry Dockerfile path to use if no custom image is provided."
  default     = "dockerfile"
}

variable "default_image_name" {
  type        = string
  description = "The default image name to use if no custom image is provided."
  default     = null
}
