terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
  required_version = "1.0.5"
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "http_server_image" {
  name = "danjellz/http-server"
}

resource "docker_container" "http_server_container" {
  count = length(var.external_port)
  image = docker_image.http_server_image.latest
  name  = "http_server-running${count.index}"

  ports {
    internal = var.internal_port
    external = var.external_port[count.index]
  }
}