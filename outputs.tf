output "memcached_namespace_host" {
  description = "Hostname of the Memcached service in the namespace"
  value       = "${kubernetes_service.memcached.metadata.0.name}:${local.port}"
}
