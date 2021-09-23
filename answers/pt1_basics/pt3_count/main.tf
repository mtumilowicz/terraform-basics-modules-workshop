resource "docker_image" "http_server_image" {
  name = "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  count = local.container_count
  image = docker_image.http_server_image.latest
  name  = "http_server-running${count.index}"

  ports {
    internal = var.internal_port
    external = var.external_ports[count.index]
  }
}