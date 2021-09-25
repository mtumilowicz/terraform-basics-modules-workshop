output "container_name_output" {
  value         = toset([for container in docker_container.http_server_container : container.name])
}

output "container_access_ip_port_output" {
  value       = [for container in docker_container.http_server_container : join(":", [container.network_data[0].ip_address], container.ports[*]["external"])]
  description = "IP + external port of the container"
}