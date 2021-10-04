terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  // host = "unix:///var/run/docker.sock" // macos
  // host = "npipe:////.//pipe//docker_engine" // windows
}