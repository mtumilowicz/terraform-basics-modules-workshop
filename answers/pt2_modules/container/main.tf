resource "docker_container" "app_container" {
  count = var.count_input
  name  = join("-", [var.name_input, count.index])
  image = var.image_input
  ports {
    internal = var.internal_port_input
    external = var.external_port_input[count.index]
  }
}

