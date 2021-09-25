resource "docker_image" "http_server_image" {
  name = "..."
}

resource "docker_container" "http_server_container" {
  image = "..."
  name  = "..."

  ports {
    internal = 0
    external = 0
  }
}