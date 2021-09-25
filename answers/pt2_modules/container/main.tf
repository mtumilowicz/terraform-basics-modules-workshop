resource "docker_container" "app_container" {
  count = var.containers_to_create_count_input
  name  = join("-", [var.container_prefix_name_input, count.index])
  image = var.image_name_input
  ports {
    internal = var.internal_port_input
    external = var.external_port_input[count.index]
  }
}

