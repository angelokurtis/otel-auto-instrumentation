locals {
  prometheus = {
    namespace       = kubernetes_namespace_v1.prometheus.metadata[0].name
    chart           = "prometheus"
    helm_repository = "prometheus-community"
    values          = {
      nodeExporter     = { enabled = false }
      kubeStateMetrics = { enabled = false }
      pushgateway      = { enabled = false }
      alertmanager     = { enabled = false }
      server           = {
        extraFlags = ["web.enable-remote-write-receiver"]
        ingress    = { enabled = true, hosts = ["prometheus.${local.cluster_host}"], ingressClassName = "traefik" }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prom" }
}
