variable "images" {
  type        = map(any)
  description = "image for container"
}

variable "http_server" {
  default = "http_server"
}

variable "external_ports" {
  type = map(any)

  validation {
    condition     = max(var.external_ports["http_server"]...) <= 65535 && min(var.external_ports["http_server"]...) >= 1980
    error_message = "The external port must be in the valid port range 1980 - 65535."
  }
}

variable "internal_port" {
  type    = number
  default = 8080

  validation {
    condition     = var.internal_port == 8080
    error_message = "The internal port must be 8080."
  }
}

