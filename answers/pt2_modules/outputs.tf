output "containers_ip_port_output" {
  value       = [for container in module.container[*] : container]
}