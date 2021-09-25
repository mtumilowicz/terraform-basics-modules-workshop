output "container_name_output" {
  value = "... container names" // hint: docker_container.http_server_container, splat expression, [*], name
}

output "container_access_ip_port_output" {
  // hint: for container, docker_container.http_server_container[*], join, container.network_data[0].ip_address, container.ports[*]["external"]
  value       =  "... ip:port"
  description = "IP + external port of the container"
}