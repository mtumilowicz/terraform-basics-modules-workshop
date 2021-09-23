output "application_access_output" {
  value       = [for container in module.container[*] : container]
  description = "The name and socket for each application."
}