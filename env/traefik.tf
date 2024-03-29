locals {
  traefik = {
    service      = { type = "NodePort" }
    ingressClass = { enabled = true, isDefaultClass = true }
    nodeSelector = { "ingress-ready" = "true", "kubernetes.io/os" = "linux" }
    ports        = {
      traefik   = { expose = true, nodePort = 32090 }
      web       = { nodePort = 32080 }
      websecure = { nodePort = 32443 }
    }
    providers = {
      kubernetesCRD     = { namespaces = ["default", "traefik"] }
      kubernetesIngress = {
        namespaces       = ["default", "traefik"]
        publishedService = { enabled = true }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}
