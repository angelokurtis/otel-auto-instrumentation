locals {
  opentelemetry_operator = {
    namespace       = kubernetes_namespace_v1.opentelemetry.metadata[0].name
    helm_repository = "opentelemetry"
    values          = {
      manager = {
        image = {
          repository = "ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator"
          tag        = "0.58.0"
        }
      }
    }
    dependsOn = [{ name = "cert-manager", namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name }]
  }
}

resource "kubernetes_job_v1" "wait_opentelemetry_crds" {
  metadata {
    name      = "wait-opentelemetry-crds"
    namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.opentelemetry_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = [
            "wait", "--for=condition=Ready", "helmrelease/opentelemetry-operator", "--timeout", var.default_timeouts
          ]
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true

  timeouts {
    create = var.default_timeouts
    update = var.default_timeouts
  }

  depends_on = [
    kubernetes_role_binding_v1.kubectl_opentelemetry_helmreleases_reader,
    kubectl_manifest.helm_release["opentelemetry-operator"],
  ]
}

resource "kubernetes_service_account_v1" "opentelemetry_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name
  }
}

resource "kubernetes_role_v1" "opentelemetry_helmreleases_reader" {
  metadata {
    name      = "opentelemetry-helmreleases-reader"
    namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_opentelemetry_helmreleases_reader" {
  metadata {
    name      = "kubectl-opentelemetry-helmreleases-reader"
    namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.opentelemetry_helmreleases_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.opentelemetry_kubectl.metadata[0].name
    namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name
  }
}

resource "kubernetes_namespace_v1" "opentelemetry" {
  metadata { name = "otel" }
}
