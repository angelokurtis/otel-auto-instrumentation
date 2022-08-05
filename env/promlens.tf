resource "kubectl_manifest" "promlens_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: promlens
  namespace: ${kubernetes_namespace.promlens.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: promlens
      sourceRef:
        kind: HelmRepository
        name: ricardo
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    config:
      web:
        default_prometheus_url: "http://prometheus.lvh.me/"
        external_url: "http://promlens.lvh.me/"
      shared_links:
        gcs:
          enabled: false
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.ricardo_helm_repository
  ]
}

resource "kubernetes_ingress_v1" "promlens" {
  metadata {
    name      = "promlens"
    namespace = kubernetes_namespace.promlens.metadata[0].name
  }
  spec {
    rule {
      host = "promlens.${local.cluster_host}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "promlens"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace" "promlens" {
  metadata { name = var.promlens_namespace }
}
