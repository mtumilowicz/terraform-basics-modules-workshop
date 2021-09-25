variable "http_server_config" {
  // hint: [ key = { name = ..., ports = map } ]
  type = any // hint: map(object({})), map(any)
}

variable "internal_port_default" {
  type    = number
  default = 8080
}