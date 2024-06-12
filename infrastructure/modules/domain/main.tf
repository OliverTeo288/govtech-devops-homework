resource "aws_route53_zone" "main" {
  name = var.hosted_zone_domain
}

resource "cloudflare_record" "example_ns" {
  for_each = {
    for idx, ns in aws_route53_zone.main.name_servers : idx => ns
  }

  zone_id = var.cloudflare_zone_id
  name    = var.hosted_zone_domain
  type    = "NS"
  ttl     = 3600
  value   = each.value
}

resource "aws_route53_record" "acm_records" {

  for_each = {
    for dvo in var.app_acm_domains.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

# resource "aws_route53_record" "cf_acm_records" {

#   for_each = {
#     for dvo in var.cf_app_acm_domains.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   zone_id = aws_route53_zone.main.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 300
#   records = [each.value.record]
# }


resource "aws_route53_record" "alb_record" {

  zone_id = aws_route53_zone.main.zone_id
  name    = var.hosted_zone_domain
  type    = "A"
  alias {
    name    = var.cf_domain_name
    zone_id = var.cf_zone_id
    # ALB Only
    # name                   = var.hw_ingress_domain
    # zone_id                = var.hw_ingress_zone_id
    evaluate_target_health = true
  }
}