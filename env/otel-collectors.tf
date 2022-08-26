locals {
  opentelemetry_collectors = {
    otlp = {
      mode        = "deployment"
      config_file = "otel-collectors/otlp.yaml"
      env         = {
        OTLP_ENDPOINT = "jaeger-collector.${kubernetes_namespace_v1.jaeger.metadata[0].name}.svc.cluster.local:${local.jaeger.collector.otlp.port}"
      }
    }
  }
}

resource "kubectl_manifest" "otelcol" {
  for_each = local.opentelemetry_collectors

  server_side_apply = true
  yaml_body         = <<YAML
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: ${each.key}
  namespace: ${kubernetes_namespace_v1.opentelemetry.metadata[0].name}
spec:
  image: docker.io/kurtis/otel-collector:v1.0.3
  mode: ${each.value.mode}
  config: '${jsonencode(yamldecode(file(each.value.config_file)))}'
  env: ${jsonencode([for k, v in local.opentelemetry_collectors.otlp.env : { name = k, value = v }])}
YAML

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_opentelemetry_crds]
}
