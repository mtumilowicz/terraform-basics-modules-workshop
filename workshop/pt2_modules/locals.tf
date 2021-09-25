// it cannot be variable, because
// functions may not be called in tfvars
// variable may not be used in tfvars
locals {
  // hint: containers = { name -> [ containers_to_create_count = ..., image = ...,  internal_port = ..., external_port = ...] }
  // hint: http_server, length(var.external_ports[var.http_server]), var.images[var.http_server], 8080, var.external_ports[var.http_server]
}



