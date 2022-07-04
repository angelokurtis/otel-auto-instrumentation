locals {
  cluster_host     = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  default_timeouts = "5m"
  kind             = { version = "v1.23.6" }
  fluxcd           = {
    version           = "v0.31.1"
    default_interval  = "10s"
    default_timeout   = "5m"
    source_controller = { host = "source-controller.${local.cluster_host}" }
  }
  jaeger = {
    query     = { host = "jaeger.${local.cluster_host}" }
    collector = { host = "jaeger-collector.${local.cluster_host}" }
    storage   = { keyspace = "jaeger_v1_test" }
  }
  opentelemetry = {
    operator = { version = "0.54.0" }
  }
}
