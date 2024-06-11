output "alb_security_group" {
  value = aws_security_group.alb_security_group
}

output "app_security_group" {
  value = aws_security_group.app_security_group
}