output "container_access_ip_port_output" {
  // hint: containerName -> container.network_data[0].ip_address-container.ports[*]["external"]
  // hint: for container, docker_container.app_container[*], container => join, network_data[0].ip_address, ports[*]["external"]
  description = "containerName -> IP + external port of the container"
}