terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
  required_version = "1.0.5" // required_version setting applies only to the version of Terraform CLI. Terraform's resource types are implemented by provider plugins, whose release cycles are independent of Terraform CLI and of each other
}

provider "docker" { }

resource "docker_image" "hello_word_image" {
  name = "hello-world:latest"
}

resource "docker_container" "hello_word_container" {
  image = docker_image.hello_word_image.id
  name  = "hello-word-running"
}