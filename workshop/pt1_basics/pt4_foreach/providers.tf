terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
  required_version = "1.0.5"
}

provider "docker" {
  // host = "unix:///var/run/docker.sock" // macos
  // host = "npipe:////.//pipe//docker_engine" // windows
}