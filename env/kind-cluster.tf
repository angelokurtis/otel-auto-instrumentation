locals {
  cluster_host = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  kind         = { version = "v1.23.12" }
}

resource "kind_cluster" "otel" {
  name = "otel"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node:${local.kind.version}"
    }

    node {
      role  = "worker"
      image = "kindest/node:${local.kind.version}"
    }

    node {
      role  = "worker"
      image = "kindest/node:${local.kind.version}"

      kubeadm_config_patches = [
        yamlencode({
          kind             = "JoinConfiguration"
          nodeRegistration = { kubeletExtraArgs = { "node-labels" = "ingress-ready=true" } }
        })
      ]

      extra_port_mappings {
        container_port = 32080
        host_port      = 80
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 32443
        host_port      = 443
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 32090
        host_port      = 9000
        protocol       = "TCP"
      }
    }
  }
}
