resource "kubectl_manifest" "jaeger_operator_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: jaeger-operator
  namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: jaeger-operator
      sourceRef:
        kind: HelmRepository
        name: jaeger
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    rbac:
      clusterRole: true
    extraEnv:
      - name: LOG-LEVEL
        value: debug
      - name: ES-PROVISION
        value: "no"
      - name: KAFKA-PROVISION
        value: "no"
  dependsOn:
    - name: cert-manager
      namespace: ${kubernetes_namespace.cert_manager.metadata[0].name}
    - name: cassandra
      namespace: ${kubernetes_namespace.cassandra.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.jaeger_helm_repository
  ]
}

resource "kubernetes_secret_v1" "storage_credentials" {
  metadata {
    name      = "storage-credentials"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  data = {
    CASSANDRA_USERNAME = "cassandra"
    CASSANDRA_PASSWORD = random_password.cassandra.result
  }
}

resource "kubectl_manifest" "jaeger" {
  yaml_body = <<YAML
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
  namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
spec:
  strategy: production
  ingress:
    enabled: true
    hosts:
      - ${local.jaeger.query.host}
    ingressClassName: traefik
  agent:
    image: jaegertracing/jaeger-agent:${local.jaeger.version}
  collector:
    image: jaegertracing/jaeger-collector:${local.jaeger.version}
  query:
    image: jaegertracing/jaeger-query:${local.jaeger.version}
  storage:
    type: cassandra
    cassandraCreateSchema:
      image: jaegertracing/jaeger-cassandra-schema:${local.jaeger.version}
    options:
      cassandra:
        servers: cassandra.cassandra.svc.cluster.local
        port: 9042
        keyspace: ${local.jaeger.storage.keyspace}
    secretName: ${kubernetes_secret_v1.storage_credentials.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.jaeger_operator_helm_release,
    kubernetes_job_v1.wait_jaeger_crds
  ]
}

resource "kubernetes_job_v1" "wait_jaeger_crds" {
  metadata {
    name      = "wait-jaeger-crds"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.jaeger_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = ["wait", "--for=condition=Ready", "helmrelease/jaeger-operator", "--timeout", local.default_timeouts]
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
    kubernetes_role_binding_v1.kubectl_jaeger_helmreleases_reader,
    kubectl_manifest.jaeger_operator_helm_release,
  ]
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.otel]
}

resource "kubernetes_service_account_v1" "jaeger_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
}

resource "kubernetes_role_v1" "jaeger_helmreleases_reader" {
  metadata {
    name      = "jaeger-helmreleases-reader"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_jaeger_helmreleases_reader" {
  metadata {
    name      = "kubectl-jaeger-helmreleases-reader"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.jaeger_helmreleases_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.jaeger_kubectl.metadata[0].name
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
}

resource "kubernetes_namespace" "jaeger" {
  metadata { name = var.jaeger_namespace }
}
