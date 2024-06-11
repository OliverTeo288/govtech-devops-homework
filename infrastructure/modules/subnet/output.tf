output "public_subnet_a" {
  value = aws_subnet.hw_subnets["public-subnet-a"]
}

output "public_subnet_b" {
  value = aws_subnet.hw_subnets["public-subnet-b"]
}

output "app_subnet_a" {
  value = aws_subnet.hw_subnets["app-subnet-a"]
}

output "app_subnet_b" {
  value = aws_subnet.hw_subnets["app-subnet-b"]
}


output "db_subnet_a" {
  value = aws_subnet.hw_subnets["db-subnet-a"]
}

output "db_subnet_b" {
  value = aws_subnet.hw_subnets["db-subnet-b"]
}

output "inspection_subnet_a" {
  value = aws_subnet.hw_subnets["inspection-subnet-a"]
}

output "inspection_subnet_b" {
  value = aws_subnet.hw_subnets["inspection-subnet-b"]
}