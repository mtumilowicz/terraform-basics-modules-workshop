locals {
  deployment = {
    nodered = {
      container_count = length(var.ext_port["nodered"])
      image           = var.image["nodered"]
      int             = 8080
      ext             = var.ext_port["nodered"]
    }
  }
}



