resource "kubectl_manifest" "cassandra_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: cassandra
  namespace: ${kubernetes_namespace.cassandra.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: cassandra
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    initDBConfigMap: ${kubernetes_config_map_v1.cassandra_init_db.metadata[0].name}
    dbUser:
      existingSecret: ${kubernetes_secret_v1.cassandra.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.bitnami_helm_repository
  ]
}

resource "kubernetes_config_map_v1" "cassandra_init_db" {
  metadata {
    name      = "cassandra-init-db"
    namespace = kubernetes_namespace.cassandra.metadata[0].name
  }
  data = {
    "keyspaces.cql" = "CREATE KEYSPACE IF NOT EXISTS ${local.jaeger.storage.keyspace} WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3 };"
  }
}

resource "random_password" "cassandra" {
  length   = 16
  special  = false
}

resource "kubernetes_secret_v1" "cassandra" {
  metadata {
    name      = "cassandra"
    namespace = kubernetes_namespace.cassandra.metadata[0].name
  }
  data = {
    cassandra-password = random_password.cassandra.result
  }
}

resource "kubernetes_namespace" "cassandra" {
  metadata { name = var.cassandra_namespace }
}
