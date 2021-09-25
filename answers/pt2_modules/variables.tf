variable "images" {
  type        = map(string)
  description = "map containerId -> imageName"
}

variable "http_server" {
  default = "http_server"
}

variable "external_ports" {
  type = map(any)

  validation {
    condition     = max(var.external_ports["http_server"]...) <= 10000 && min(var.external_ports["http_server"]...) >= 0
    error_message = "The external port must be in range [0; 10000]."
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

