resource "kubectl_manifest" "opensearch_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: opensearch
  namespace: ${kubernetes_namespace.opensearch.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: opensearch
      version: 1.8.3
      sourceRef:
        kind: HelmRepository
        name: opensearch
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    replicas: 2
    protocol: http
    config:
      opensearch.yml: |
        cluster.name: opensearch-cluster
        network.host: 0.0.0.0
        plugins:
          security:
            disabled: true
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.opensearch_helm_repository
  ]
}

resource "kubectl_manifest" "opensearch_dashboards_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: opensearch-dashboards
  namespace: ${kubernetes_namespace.opensearch.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: opensearch-dashboards
      version: 1.2.2
      sourceRef:
        kind: HelmRepository
        name: opensearch
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    opensearchHosts: "http://opensearch-cluster-master:9200"
    ingress:
      enabled: true
      ingressClassName: traefik
      hosts:
        - host: ${local.opensearch.dashboard.host}
          paths:
            - path: /
              backend:
                serviceName: opensearch-dashboards
                servicePort: 5601
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.opensearch_helm_repository
  ]
}

resource "kubernetes_namespace" "opensearch" {
  metadata { name = var.opensearch_namespace }
}
