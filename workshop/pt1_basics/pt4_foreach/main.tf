resource "docker_image" "http_server_image" {
  name = "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  for_each = {} // hint: var.http_server_config
  image = docker_image.http_server_image.latest
  name  = "... what defined in config" // hint: each.key

  ports {
    // hint: get internal_port from config or default
    // hint: lookup, each.value.ports, "internal_port", var.internal_port_default
    internal = 0
    // hint: get external_port from map
    // hint: each.value.ports.external_port
    external = 0
  }
}