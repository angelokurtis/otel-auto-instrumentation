resource "kubectl_manifest" "prometheus_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: prometheus
  namespace: ${kubernetes_namespace.prometheus.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: kube-prometheus-stack
      sourceRef:
        kind: HelmRepository
        name: prometheus-community
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    grafana:
      ingress:
        enabled: true
        hosts:
          - grafana.${local.cluster_host}
    prometheus:
      ingress:
        enabled: true
        hosts:
          - prometheus.${local.cluster_host}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.prometheus_community_helm_repository
  ]
}

resource "kubernetes_namespace" "prometheus" {
  metadata { name = var.prometheus_namespace }
}
