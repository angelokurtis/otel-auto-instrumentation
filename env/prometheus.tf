locals {
  prometheus = {
    namespace       = kubernetes_namespace_v1.prometheus.metadata[0].name
    chart           = "prometheus"
    helm_repository = "prometheus-community"
    values          = {
      nodeExporter     = { enabled = false }
      kubeStateMetrics = { enabled = false }
      server           = {
        ingress = { enabled = true, hosts = ["prometheus.${local.cluster_host}"], ingressClassName = "traefik" }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prom" }
}
