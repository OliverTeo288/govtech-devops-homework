resource "kubernetes_ingress_v1" "hw_ingress" {
  metadata {
    name = "hw-ingress"

    annotations = {
      "kubernetes.io/ingress.class"            = "alb"
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"  = "ip"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = jsonencode({
        "Type" : "redirect",
        "RedirectConfig" : {
          "Protocol" : "HTTPS",
          "Port" : "443",
          "StatusCode" : "HTTP_301"
        }
      })
      "alb.ingress.kubernetes.io/certificate-arn"  = var.app_acm_arn
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
              name = "ssl-redirect"
              port {
                name = "use-annotation"
              }
            }
          }
        }

        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.example.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name      = "hw-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "example"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "example" {
  metadata {
    name      = "example-deployment"
    namespace = "default"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "example"
      }
    }

    template {
      metadata {
        labels = {
          app = "example"
        }
      }

      spec {
        container {
          name  = "example"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}