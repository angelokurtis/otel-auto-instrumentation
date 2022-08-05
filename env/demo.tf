resource "kubectl_manifest" "opentelemetry_instrumentation" {
  yaml_body = <<YAML
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: default
  namespace: ${kubernetes_namespace.demo.metadata[0].name}
spec:
  exporter:
    endpoint: http://default-collector.${kubernetes_namespace.opentelemetry.metadata[0].name}.svc.cluster.local:4317
  sampler:
    type: parentbased_always_on
  java:
    image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:1.16.0
    env:
      - name: OTEL_METRICS_EXPORTER
        value: prometheus
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.opentelemetry_operator_helm_release,
    kubernetes_job_v1.wait_opentelemetry_crds
  ]
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name        = "demo"
    annotations = { "instrumentation.opentelemetry.io/inject-java" : "true" }
  }
}
