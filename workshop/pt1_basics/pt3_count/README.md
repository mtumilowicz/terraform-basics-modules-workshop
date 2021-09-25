1. goal: run two containers from the image: "danjellz/http-server" using meta-argument count
1. hints
    1. define `variables.tf` for external_ports and internal_port (with validations)
        * internal: should be 8080
        * external: [0, 10000]
    1. set external_ports in `terraform.tfvars` for [8080,8081]
    1. define outputs for container names and ip addresses using splat expression [*]
    1. define container_count as a local variable: length(var.external_port)
    1. use it in meta-argument count in container definition
        * name should be based on the count.index
1. verify: http://127.0.0.1:8080/test.html
1. verify: http://127.0.0.1:8081/test.html