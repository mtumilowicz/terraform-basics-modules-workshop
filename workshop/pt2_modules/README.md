1. goal: run two containers from the image: "danjellz/http-server" using modules
1. hints
    1. define directories for modules: container, image
    1. module container
        * inputs: external port, internal port, containers to create, image name and container prefix name
        * outputs: ip ports for access
        * main: as a base use pt3_count
    1. module image
        * inputs: image name
        * output: image name
        * main: just `resource "docker_image"` with input name
    1. root module
        *
1. verify: http://127.0.0.1:8080/test.html
1. verify: http://127.0.0.1:8081/test.html