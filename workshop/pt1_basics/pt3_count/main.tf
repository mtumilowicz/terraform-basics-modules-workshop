resource "docker_image" "http_server_image" {
  name = "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  count = 0 // hint: containers_to_create_count from locals
  image = docker_image.http_server_image.latest
  name  = "..." // hint: "http_server-running{number of container}", ${count.index}

  ports {
    internal = 0 // hint: var.internal_port
    external = 0 // hint: var.external_ports for current container, external_ports[count.index]
  }
}