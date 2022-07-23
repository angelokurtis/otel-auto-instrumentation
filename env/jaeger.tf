resource "kubectl_manifest" "jaeger_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: jaeger
  namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: jaeger
      sourceRef:
        kind: HelmRepository
        name: jaeger
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    agent:
      enabled: false
    collector:
      cmdlineParams:
        log-level: debug
      service:
        otlp:
          grpc:
            port: ${local.jaeger.collector.otlp.port}
    query:
      cmdlineParams:
        log-level: debug
      ingress:
        enabled: true
        hosts:
          - ${local.jaeger.query.host}
        ingressClassName: traefik
    provisionDataStore:
      cassandra: false
      elasticsearch: false
    storage:
      type: elasticsearch
      elasticsearch:
        scheme: http
        host: opensearch-cluster-master.${kubernetes_namespace.opensearch.metadata[0].name}.svc.cluster.local
        port: 9200
        user: admin
        password: admin
        cmdlineParams:
          es.index-prefix: jaeger_
          es.version: 7
          es.log-level: debug
          es.create-index-templates: true
    esIndexCleaner:
      enabled: true
      numberOfDays: 2
  dependsOn:
    - name: opensearch
      namespace: ${kubernetes_namespace.opensearch.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.jaeger_helm_release,
    kubectl_manifest.opensearch_helm_release
  ]
}

resource "kubernetes_namespace" "jaeger" {
  metadata { name = var.jaeger_namespace }
}
