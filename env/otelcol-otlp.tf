resource "kubectl_manifest" "otlp_opentelemetry_collector" {
  yaml_body = <<YAML
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: otlp
  namespace: ${kubernetes_namespace.opentelemetry.metadata[0].name}
spec:
  image: otel/opentelemetry-collector:${local.opentelemetry.collector.version}
  mode: deployment
  config: |
    receivers:
      otlp:
        protocols:
          grpc:
          http:

    processors:
      batch:
        send_batch_size: 10000
        timeout: 1s

    exporters:
      otlp:
        endpoint: jaeger-collector.${kubernetes_namespace.jaeger.metadata[0].name}.svc.cluster.local:${local.jaeger.collector.otlp.port}
        tls:
          insecure: true
      prometheus:
        endpoint: "0.0.0.0:8889"

    extensions:
      health_check:
        endpoint: "0.0.0.0:13133"

    service:
      extensions: [ health_check ]

      pipelines:
        traces:
          receivers: [ otlp ]
          processors: [ batch ]
          exporters: [ otlp ]
        metrics:
          receivers: [ otlp ]
          processors: [ batch ]
          exporters: [ prometheus ]
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.opentelemetry_operator_helm_release,
    kubernetes_job_v1.wait_opentelemetry_crds
  ]
}