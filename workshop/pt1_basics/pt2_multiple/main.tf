resource "docker_image" "http_server_image" {
  name = "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  image = docker_image.http_server_image.latest
  name  = "http_server-running"

  ports {
    internal = 8080
    external = 8080
  }
}

resource "docker_container" "http_server_container2" {
  image = "..."
  name  = "..."

  ports {
    internal = 0
    external = 0
  }
}