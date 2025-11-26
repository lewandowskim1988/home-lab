variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = ""
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
  default     = ""
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
      image        = string
    }))
    workers = map(object({
      install_disk = string
      hostname     = optional(string)
      image        = string
    }))
  })
  default = {
    controlplanes = {
      "" = {
        install_disk = ""
        image        = ""
      }
    }
    workers = {}
  }
}
