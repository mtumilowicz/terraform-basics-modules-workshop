output "container-name" {
  value         = toset([for bd in docker_container.http_server_container : bd.name])
  description = "The name of the container"
}

output "ip-address" {
  value       = [for i in docker_container.http_server_container : join(":", [i.ip_address], i.ports[*]["external"])]
  description = "The IP address and external port of the container"
}