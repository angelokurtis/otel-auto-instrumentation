locals {
  jaeger = {
    namespace       = kubernetes_namespace_v1.jaeger.metadata[0].name
    chart           = "jaeger-operator"
    helm_repository = kubectl_manifest.helm_repository["jaegertracing"]
    values          = {
      fullnameOverride = "jaeger-operator"
      rbac             = { clusterRole = true }
      jaeger           = {
        create = true
        spec   = {
          ingress  = { enabled = true, hosts = ["jaeger.lvh.me"], ingressClassName = "traefik" }
          storage  = { type = "memory" }
          strategy = "allinone"
        }
      }
    }
    dependsOn = [{ name = "cert-manager", namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name }]
  }
}

resource "kubernetes_namespace_v1" "jaeger" {
  metadata { name = "jaeger" }
}
