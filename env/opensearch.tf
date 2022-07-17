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
    extraInitContainers:
      - name: init-sysctl
        image: busybox:latest
        imagePullPolicy: IfNotPresent
        command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash
          set -euo pipefail
          CURRENT=`sysctl -n vm.max_map_count`;
          DESIRED="262144";
          if [ "$DESIRED" -gt "$CURRENT" ]; then
              sysctl -w vm.max_map_count=262144;
          fi;
        securityContext:
          runAsUser: 0
          privileged: true
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
      version: 1.1.2
      sourceRef:
        kind: HelmRepository
        name: opensearch
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    imageTag: "1.1.0"
    opensearchHosts: "http://opensearch-cluster-master.${kubernetes_namespace.opensearch.metadata[0].name}.svc.cluster.local:9200"
    opensearchAccount:
      secret: ${kubernetes_secret_v1.opensearch.metadata[0].name}
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

resource "kubernetes_secret_v1" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = kubernetes_namespace.opensearch.metadata[0].name
  }
  data = {
    username = "admin"
    password = "admin"
    cookie   = "378dc9cf-c1e2-4d62-9f3f-ac52038cbcd9"
  }
}

resource "kubernetes_namespace" "opensearch" {
  metadata { name = var.opensearch_namespace }
}
