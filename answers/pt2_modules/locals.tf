locals {
  containers = {
    http_server = {
      containers_to_create_count = length(var.external_ports[var.http_server])
      image                      = var.image[var.http_server]
      int                        = 8080
      ext                        = var.external_ports[var.http_server]
    }
  }
}



