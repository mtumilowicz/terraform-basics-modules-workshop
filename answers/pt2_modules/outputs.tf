output "containers_output" {
  value       = [for container in module.container[*] : container]
}