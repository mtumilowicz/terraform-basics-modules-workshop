output "container_access_ip_port_output" {
  value = { for container in docker_container.app_container[*] : container.name => join(":", [container.network_data[0].ip_address], container.ports[*]["external"]) }
  description = "containerName -> IP + external port of the container"
}