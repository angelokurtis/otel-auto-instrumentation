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

resource "kubernetes_namespace" "opentelemetry" {
  metadata { name = var.opentelemetry_namespace }
}
