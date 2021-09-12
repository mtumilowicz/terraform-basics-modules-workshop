terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}


provider "docker" {
  host = "npipe:////.//pipe//docker_engine" // windows: https://github.com/hashicorp/terraform-provider-docker/issues/180
}