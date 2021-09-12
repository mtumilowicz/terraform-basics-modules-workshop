resource "docker_container" "app_container" {
  count = var.count_in
  name  = join("-", [var.name_in, count.index])
  image = var.image_in
  ports {
    internal = var.int_port_in
    external = var.ext_port_in[count.index]
  }
}

