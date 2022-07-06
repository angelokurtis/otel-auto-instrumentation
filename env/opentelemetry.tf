resource "kubectl_manifest" "opentelemetry_operator_helm_release" {
  yaml_body = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: opentelemetry-operator
  namespace: ${kubernetes_namespace.opentelemetry.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  prune: true
  path: config/default
  sourceRef:
    kind: GitRepository
    name: opentelemetry-operator
    namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  images:
    - name: controller
      newName: ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator
      newTag: ${local.opentelemetry.operator.version}
  targetNamespace: ${kubernetes_namespace.opentelemetry.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.opentelemetry_operator_git_repository
  ]
}

resource "kubectl_manifest" "open_telemetry_collector_helm_release" {
  yaml_body = <<YAML
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: open-telemetry-collector
  namespace: ${kubernetes_namespace.opentelemetry.metadata[0].name}
spec:
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
        endpoint: opentelemetry-collector.${kubernetes_namespace.opentelemetry.metadata[0].name}.svc.cluster.local:4317
        tls:
          insecure: true
    
    service:
      pipelines:
        traces:
          receivers: [ otlp ]
          processors: [ batch ]
          exporters: [ otlp ]
        metrics:
          receivers: [ otlp ]
          processors: [ batch ]
          exporters: [ otlp ]
        logs:
          receivers: [ otlp ]
          processors: [ batch ]
          exporters: [ otlp ]
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.opentelemetry_operator_helm_release,
    kubernetes_job_v1.wait_opentelemetry_crds
  ]
}

resource "kubernetes_job_v1" "wait_opentelemetry_crds" {
  metadata {
    name      = "wait-opentelemetry-crds"
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.opentelemetry_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = ["wait", "--for=condition=Ready", "kustomization/opentelemetry-operator", "--timeout", local.default_timeouts]
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true

  timeouts {
    create = local.default_timeouts
    update = local.default_timeouts
  }

  depends_on = [
    kubernetes_role_binding_v1.kubectl_opentelemetry_kustomizations_reader,
    kubectl_manifest.opentelemetry_operator_helm_release,
  ]
}

resource "kubernetes_service_account_v1" "opentelemetry_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
}

resource "kubernetes_role_v1" "opentelemetry_kustomizations_reader" {
  metadata {
    name      = "opentelemetry-kustomizations-reader"
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
  rule {
    api_groups = ["kustomize.toolkit.fluxcd.io"]
    resources  = ["kustomizations"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_opentelemetry_kustomizations_reader" {
  metadata {
    name      = "kubectl-opentelemetry-kustomizations-reader"
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.opentelemetry_kustomizations_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.opentelemetry_kubectl.metadata[0].name
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
}

resource "kubernetes_namespace" "opentelemetry" {
  metadata { name = var.opentelemetry_namespace }
}
