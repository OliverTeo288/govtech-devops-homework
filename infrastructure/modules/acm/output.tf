output "app_cert" {
  value = aws_acm_certificate.app_cert
}

# output "app_cert_arn" {
#   value = aws_acm_certificate_validation.app_cert_validation.certificate_arn
# }
