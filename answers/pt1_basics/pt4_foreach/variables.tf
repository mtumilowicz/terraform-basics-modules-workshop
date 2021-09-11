variable "http_server_config" {
  type = map(object(
  {
    name = string
    ports = map(any)
  })
  )
}

variable "internal_port_default" {
  type    = number
  default = 8080
}