resource "kubectl_manifest" "opentelemetry_collector_otlp" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "otlp", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      config   = file("opentelemetry/otlp.yaml")
      mode     = "deployment"
      replicas = 1
      env      = [
        {
          name  = "JAEGER_OTLP_ENDPOINT",
          value = "jaeger-collector.${kubernetes_namespace_v1.jaeger.metadata[0].name}.svc.cluster.local:4317"
        },
        {
          name  = "PROMETHEUS_PUSHGATEWAY_ENDPOINT",
          value = "prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}.svc.cluster.local:80"
        },
      ]
      podAnnotations = { "prometheus.io/scrape" = "true", "prometheus.io/port" = "8888" }
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}
