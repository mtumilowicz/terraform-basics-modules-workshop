resource "docker_image" "http_server_image" {
  name = "..." // hint: "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  image = "..." // hint: docker_image.http_server_image.latest
  name  = "..." // hint: "http_server-running"

  ports {
    internal = 0 // hint: 8080
    external = 0 // hint: 8081
  }
}