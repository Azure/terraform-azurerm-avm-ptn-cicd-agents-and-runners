variable "container_cpu" {
  type        = number
  description = "Required CPU in cores, e.g. 0.5"
}

variable "container_memory" {
  type        = string
  description = "Required memory, e.g. '250Mb'"
}

variable "container_name" {
  type        = string
  description = "The name of the container for the runner Container Apps job."
}
