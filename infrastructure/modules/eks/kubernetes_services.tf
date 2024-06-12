### Ingress

resource "kubernetes_ingress_v1" "hw_ingress" {
  metadata {
    name = "hw-ingress"

    annotations = {
      "kubernetes.io/ingress.class"            = "alb"
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"  = "ip"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"
      # "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      # "alb.ingress.kubernetes.io/actions.ssl-redirect" = jsonencode({
      #   "Type" : "redirect",
      #   "RedirectConfig" : {
      #     "Protocol" : "HTTPS",
      #     "Port" : "443",
      #     "StatusCode" : "HTTP_301"
      #   }
      # })
      # "alb.ingress.kubernetes.io/certificate-arn"  = var.app_acm_arn
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }
  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.hw_app_service.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
  # spec {
  #   rule {

  #     http {
  #       path {
  #         path      = "/"
  #         path_type = "Prefix"
  #         backend {
  #           service {
  #             name = "ssl-redirect"
  #             port {
  #               name = "use-annotation"
  #             }
  #           }
  #         }
  #       }

  #       path {
  #         path      = "/"
  #         path_type = "Prefix"
  #         backend {
  #           service {
  #             name = kubernetes_service.hw_app_service.metadata[0].name
  #             port {
  #               number = 3000
  #             }
  #           }
  #         }
  #       }
  #     }
  #   }
  # }
}

### Application

resource "kubernetes_service" "hw_app_service" {
  metadata {
    name      = "hw-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "hw-app"
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "hw_app_deployment" {
  metadata {
    name      = "hw-app-deployment"
    namespace = "default"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "hw-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "hw-app"
        }
      }

      spec {
        container {
          name  = "hw-app"
          image = "${var.app_ecr}:latest"

          port {
            container_port = 3000
          }
          env {
            name  = "REDIS_HOST"
            value = "redis-service"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [spec, metadata]
  }
}

### DB Service

resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis-deployment"
    namespace = "default"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:latest"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}