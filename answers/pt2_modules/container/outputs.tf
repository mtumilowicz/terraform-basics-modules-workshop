output "application_access_output" {
  value = { for container in docker_container.app_container[*] : container.name => join(":", [container.ip_address], container.ports[*]["external"]) }
}