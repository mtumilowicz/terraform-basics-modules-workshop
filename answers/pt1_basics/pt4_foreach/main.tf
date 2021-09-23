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
  for_each = var.http_server_config
  image = docker_image.http_server_image.latest
  name  = each.key

  ports {
    internal = lookup(each.value.ports, "internal_port", var.internal_port_default)
    external = each.value.ports.external_port
  }
}