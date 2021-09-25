output "containers_access_output" {
  value       = [for container in module.container[*] : container]
}