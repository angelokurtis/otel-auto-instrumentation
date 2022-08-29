locals {
  opentelemetry_collectors = {
    otlp = {
      config_file = "otel-collectors/otlp.yaml"
      env         = {
        OTLP_ENDPOINT = "jaeger-collector.${kubernetes_namespace_v1.jaeger.metadata[0].name}.svc.cluster.local:4317"
      }
    }
  }
}

resource "kubectl_manifest" "otelcol" {
  for_each = local.opentelemetry_collectors

  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = each.key, namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      image    = "docker.io/kurtis/otel-collector:v1.0.3"
      mode     = try(each.value.mode, "deployment")
      replicas = 1
      env      = try([for k, v in local.opentelemetry_collectors.otlp.env : { name = k, value = v }], [])
      config   = file(each.value.config_file)
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_opentelemetry_crds]
}
