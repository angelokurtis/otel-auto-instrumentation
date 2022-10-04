locals {
  bets = {
    kustomization_patches = [
      {
        target = { kind = "Deployment" }
        patch  = jsonencode([
          {
            op    = "add"
            path  = "/spec/template/metadata/annotations"
            value = {
              "instrumentation.opentelemetry.io/inject-java" = "true"
              "checksum/auto-instrumentation"                = sha256(kubectl_manifest.auto_instrumentation.yaml_body)
            }
          },
          {
            op    = "add"
            path  = "/spec/template/spec/containers/0/livenessProbe/initialDelaySeconds"
            value = 70
          },
          {
            op    = "add", path = "/spec/template/spec/containers/0/env",
            value = [{ name = "LOGGING_PATTERN_LEVEL", value = "trace_id=%mdc{trace_id} span_id=%mdc{span_id} %5p" }]
          }
        ])
      }
    ]
  }
}

resource "kubectl_manifest" "auto_instrumentation" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "Instrumentation"
    metadata   = { name = "auto-instrumentation", namespace = kubernetes_namespace_v1.demo.metadata[0].name }
    spec       = {
      sampler = { type = "always_on" }
      java    = { image = "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:1.18.0" }
      env     = [
        {
          name  = "OTEL_EXPORTER_OTLP_ENDPOINT",
          value = "http://${kubectl_manifest.opentelemetry_collector_otlp.name}-collector.${kubectl_manifest.opentelemetry_collector_otlp.namespace}.svc.cluster.local:4317"
        },
        { name = "OTEL_TRACES_EXPORTER", value = "otlp" },
        { name = "OTEL_METRICS_EXPORTER", value = "none" },
        { name = "OTEL_LOGS_EXPORTER", value = "none" },
      ]
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}

resource "kubernetes_ingress_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = "demo.${local.cluster_host}"
      http {
        path {
          path = "/bets"
          backend {
            service {
              name = "bets"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/championships"
          backend {
            service {
              name = "championships"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/matches"
          backend {
            service {
              name = "matches"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/teams"
          backend {
            service {
              name = "teams"
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

resource "kubernetes_namespace_v1" "demo" {
  metadata { name = "demo" }
}
