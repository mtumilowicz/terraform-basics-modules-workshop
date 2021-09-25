output "container_name_output" {
  // hint: cannot use splat expressions on maps, use for
  value = [] // hint: for container in docker_container.http_server_container, container.name
}

output "container_access_ip_port_output" {
  // hint: cannot use splat expressions on maps, use for
  // hint: for container in docker_container.http_server_container, join,
  // container.network_data[0].ip_address, container.ports[*]["external"]
  value       = []
  description = "IP + external port of the container"
}