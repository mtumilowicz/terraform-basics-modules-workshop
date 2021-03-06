variable "images" {
  type        = any // hint: map of strings
  description = "image for container"
}

variable "http_server" {
  default = "http_server"
}

variable "external_ports" {
  type = any // hint: map of list of numbers

  validation {
    condition     = true // hint: max, var.external_ports["http_server"], ...  max(var.external_ports["http_server"]...) <= 10000 && min(var.external_ports["http_server"]...) >= 0
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

