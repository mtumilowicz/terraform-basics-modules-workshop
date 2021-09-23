1. goal: run container from the image: "danjellz/http-server"
1. hints
    1. define required providers
        * docker
            ```
            source = "kreuzwerker/docker"
            version = "2.15.0"
            ```
    1. defined required version of terraform ("1.0.5")
    1. define "docker" provider (link host for windows if needed: "npipe:////.//pipe//docker_engine")
        * windows: https://github.com/hashicorp/terraform-provider-docker/issues/180
    1. define image: "docker_image", name = "danjellz/http-server"
    1. define container: "docker_container", remember to set internal / external ports
        * internal port should be 8080 according to "danjellz/http-server" documentation
1. verify: http://127.0.0.1:8080/test.html