variable "namespace" {
  description = "Namespace to deploy Memcached to"
  type        = string
  default     = "default"
}

variable "match_labels" {
  description = "Match labels to add to the Memcached deployment, will be added to labels as well"
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Labels to add to the Memcached deployment"
  type        = map(any)
  default     = {}
}

variable "replicas" {
  description = "Replicas to produce in the Memcached Deployment"
  type        = number
  default     = 1
}

variable "image_registry" {
  description = "Image registry, e.g. gcr.io, docker.io"
  type        = string
  default     = "docker.io"
}

variable "image_repository" {
  description = "Image to start for this pod"
  type        = string
  default     = "bitnami/memcached"
}

variable "image_tag" {
  description = "Image tag to use"
  type        = string
  default     = "1.6.9"
}

variable "container_name" {
  description = "Name of the Memcached container"
  type        = string
  default     = "memcached"
}

variable "service_name" {
  description = "Name of service to deploy"
  type        = string
  default     = "memcached"
}

variable "service_type" {
  description = "Type of service to deploy"
  type        = string
  default     = "ClusterIP"
}
