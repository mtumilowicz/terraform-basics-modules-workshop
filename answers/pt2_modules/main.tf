module "image" {
  source           = "./image"
  for_each         = local.containers
  image_name_input = each.value.image
}

module "container" {
  source                           = "./container"
  containers_to_create_count_input = each.value.containers_to_create_count
  for_each                         = local.containers
  container_prefix_name_input      = each.key
  image_name_input                 = module.image[each.key].image_output
  internal_port_input              = each.value.int
  external_port_input              = each.value.ext
}


