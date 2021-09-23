module "image" {
  source      = "./image"
  for_each    = local.deployment
  image_input = each.value.image
}

module "container" {
  source              = "./container"
  count_input         = each.value.http_servers
  for_each            = local.deployment
  name_input          = each.key
  image_input         = module.image[each.key].image_output
  internal_port_input = each.value.int
  external_port_input = each.value.ext
}


