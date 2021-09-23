1. goal: run two containers from the image: "danjellz/http-server" using count
1. hints
    1. use pt3_count as a base
    1. define var http_server_config that is a map{name: String, ports: map}
    1. set that variable in terraform.vars
    1. modify outputs using for
    1. modify docker_container using for_each
1. verify: http://127.0.0.1:8080/test.html
1. verify: http://127.0.0.1:8081/test.html