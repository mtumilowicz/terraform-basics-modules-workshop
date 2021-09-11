variable "external_port" {
  type = list(any)


  # validation {
  #   condition     = var.ext_port <= 65535 && var.ext_port > 0
  #   error_message = "The external port must be in the valid port range 0 - 65535."
  # }
}

variable "internal_port" {
  type    = number
  default = 8080

  validation {
    condition     = var.internal_port == 8080
    error_message = "The internal port must be 8080."
  }
}

locals {
  container_count = length(var.external_port)
}