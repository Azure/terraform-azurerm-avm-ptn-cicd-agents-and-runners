variable "container_cpu" {
  type        = number
  description = "Required CPU in cores, e.g. 0.5"
}

variable "container_memory" {
  type        = string
  description = "Required memory, e.g. '250Mb'"
}

variable "container_image_name" {
  type        = string
  description = "Fully qualified name of the Docker image the agents should run."
  nullable    = false
}
