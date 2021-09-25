output "container_access_ip_port" {
  value = { for container in docker_container.app_container[*] : container.name => join(":", [container.ip_address], container.ports[*]["external"]) }
}