output "app_cert" {
  value = aws_acm_certificate.app_cert
}

output "cf_app_cert" {
  value = aws_acm_certificate.cf_app_cert
}
