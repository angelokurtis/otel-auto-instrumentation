locals {
  promlens = {
    namespace       = kubernetes_namespace_v1.promlens.metadata[0].name
    chart           = "promlens"
    helm_repository = "ricardo"
    values          = {
      config = {
        web = {
          default_prometheus_url = "http://prometheus.${local.cluster_host}/"
          external_url           = "http://promlens.${local.cluster_host}/"
        }
        shared_links = { gcs = { enabled = false } }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "promlens" {
  metadata {
    name      = "promlens"
    namespace = kubernetes_namespace_v1.promlens.metadata[0].name
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

resource "kubernetes_namespace_v1" "promlens" {
  metadata { name = "promlens" }
}
