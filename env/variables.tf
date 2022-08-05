variable "docker_volume" {
  type        = string
  description = "Docker volume for kind Image caching"
}

variable "load_balancer_address" {
  type        = string
  description = "The IP addresses associated with a load balancer"
  default     = "127.0.0.1"
}

variable "fluxcd_namespace" {
  default = "fluxcd"
}

variable "traefik_namespace" {
  default = "traefik"
}

variable "jaeger_namespace" {
  default = "jaeger"
}

variable "cert_manager_namespace" {
  default = "cert-manager"
}

variable "opentelemetry_namespace" {
  default = "opentelemetry"
}

variable "cassandra_namespace" {
  default = "cassandra"
}

variable "opensearch_namespace" {
  default = "opensearch"
}

variable "prometheus_namespace" {
  default = "prometheus"
}

variable "promlens_namespace" {
  default = "promlens"
}
