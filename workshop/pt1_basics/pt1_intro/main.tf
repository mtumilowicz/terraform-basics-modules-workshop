resource "docker_image" "http_server_image" {
  name = "..." // "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  image = "..." // docker_image.http_server_image.latest
  name  = "..." // "http_server-running"

  ports {
    internal = 0 // 8080
    external = 0 // 8081
  }
}