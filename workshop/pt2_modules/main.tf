module "image" {
  source           = "" // hint: module directory, ./image/
  for_each         = [] // hint: defined in locals, local.containers
  image_name_input = "... image field in local.containers" // hint: defined as a image field in local.containers, each.value.image
}

module "container" {
  source                           = "" // hint: module directory, "./container"
  for_each                         = [] // hint: defined in locals, local.containers
  containers_to_create_count_input = 0 // hint: defined as appropriate field in local.containers, each.value.containers_to_create_count
  container_prefix_name_input      = "... http-server" // hint: defined as a key in local.containers, each.key
  image_name_input                 = "... image name from image module output" // hint: module.image[each.key].image_name_output
  internal_port_input              = 0 // hint: defined as a internal_port in local.containers, each.value.internal_port
  external_port_input              = 0 // hint: defined as a external_port in local.containers, each.value.external_port
}


