output "hw_ingress_hostname" {
  value = kubernetes_ingress_v1.hw_ingress.status[0].load_balancer[0].ingress[0].hostname
}

locals {
  alb_name = regex("^(k8s-[a-z0-9-]+)-[0-9]+\\.ap-southeast-1\\.elb\\.amazonaws\\.com$", kubernetes_ingress_v1.hw_ingress.status[0].load_balancer[0].ingress[0].hostname)[0]
}

data "aws_lb" "alb" {
  name = local.alb_name

}

output "hw_ingress_zone_id" {
  value = data.aws_lb.alb.zone_id

}