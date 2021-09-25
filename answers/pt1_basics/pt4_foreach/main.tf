resource "docker_image" "http_server_image" {
  name = "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  for_each = var.http_server_config
  image    = docker_image.http_server_image.latest
  name     = each.key

  ports {
    internal = lookup(each.value.ports, "internal_port", var.internal_port_default)
    external = each.value.ports.external_port
  }
}