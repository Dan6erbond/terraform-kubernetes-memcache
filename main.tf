terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
  }
}

locals {
  match_labels = merge({
    "app.kubernetes.io/name"     = "memcached"
    "app.kubernetes.io/instance" = "memcached"
  }, var.match_labels)
  labels = merge(local.match_labels, var.labels)
  port   = 11211
}

resource "kubernetes_service_account" "memcached" {
  metadata {
    name      = "memcached"
    namespace = var.namespace
    labels    = local.labels
  }
  automount_service_account_token = true
}

resource "kubernetes_deployment" "memcached" {
  metadata {
    name      = "memcached"
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    selector {
      match_labels = local.match_labels
    }
    replicas = var.replicas
    template {
      metadata {
        labels = local.labels
      }
      spec {
        affinity {
          pod_affinity {}
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_labels = local.match_labels
                }
                namespaces   = [var.namespace]
                topology_key = "kubernetes.io/hostname"
              }
              weight = 1
            }
          }
          node_affinity {}
        }
        security_context {
          fs_group    = 1001
          run_as_user = 1001
        }
        service_account_name = kubernetes_service_account.memcached.metadata.0.name
        container {
          name              = var.container_name
          image             = var.image_registry == "" ? "${var.image_repository}:${var.image_tag}" : "${var.image_registry}/${var.image_repository}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"
          args              = ["/run.sh"]
          env {
            name  = "BITNAMI_DEBUG"
            value = "false"
          }
          port {
            name           = "memcache"
            container_port = local.port
          }
          liveness_probe {
            tcp_socket {
              port = "memcache"
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
            failure_threshold     = 6
          }
          readiness_probe {
            tcp_socket {
              port = "memcache"
            }
            initial_delay_seconds = 5
            timeout_seconds       = 3
            period_seconds        = 5
          }
          resources {
            requests = {
              "cpu"    = "250m"
              "memory" = "256Mi"
            }
            limits = {
              "cpu"    = "500m"
              "memory" = "1Gi"
            }
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          security_context {
            read_only_root_filesystem = false
          }
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "memcached" {
  metadata {
    name      = var.service_name
    namespace = var.namespace
  }
  spec {
    type = var.service_type
    port {
      name        = "memcache"
      port        = local.port
      target_port = "memcache"
      node_port   = null
    }
    selector = local.match_labels
  }
  depends_on = [
    kubernetes_deployment.memcached
  ]
}
