locals {
  deployment = {
    http_server = {
      http_servers = length(var.external_ports[var.http_server])
      image        = var.image[var.http_server]
      int          = 8080
      ext          = var.external_ports[var.http_server]
    }
  }
}



