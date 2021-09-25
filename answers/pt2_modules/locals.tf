// it cannot be variable, because: functions may not be called in tfvars and variable may not be used in tfvars
locals {
  containers = {
    http_server = {
      containers_to_create_count = length(var.external_ports[var.http_server])
      image                      = var.images[var.http_server]
      int                        = 8080
      ext                        = var.external_ports[var.http_server]
    }
  }
}



