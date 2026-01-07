variable "stable_versions_only" {
  type    = bool
  default = true
}

variable "platform" {
  type    = string
  default = ""
}

variable "extension_names" {
  description = "List of extension names to filter"
  type        = list(string)
  default     = []
}

variable "contrib_extension_names" {
  description = "List of contrib extension names to filter"
  type        = list(string)
  default     = []
}

variable "image_container_registry" {
  type    = string
  default = "docker.io/lewandowskim"
}
