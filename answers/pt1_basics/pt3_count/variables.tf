variable "external_ports" {
  type = list(number)


  validation {
    condition     = alltrue([for port in var.external_ports : (0 <= port && port <= 10000)])
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

locals {
  container_count = length(var.external_ports)
}