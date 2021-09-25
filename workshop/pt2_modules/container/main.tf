resource "docker_container" "app_container" {
  count = 0 // hint: how many containers to create, var.containers_to_create_count_input
  name  = "... prefix-index"// hint: join, var.container_prefix_name_input, count.index
  image = "" // hint: var.image_name_input
  ports {
    internal = 0 // hint: var.internal_port_input
    external = 0 // hint: var.external_port_input[count.index]
  }
}

