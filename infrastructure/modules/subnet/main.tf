resource "aws_subnet" "hw_subnets" {
  for_each = var.subnet_details

  availability_zone = each.value["az"]
  cidr_block        = each.value["cidr"]
  vpc_id            = var.vpc_id

  tags = merge(
    {
      Name = "hw-${each.key}"
    },
    can(regex("public", lower(each.key))) ? { "kubernetes.io/role/elb" = "1" } : {},
    can(regex("app", lower(each.key))) ? { "kubernetes.io/role/internal-elb" = "1" } : {}
  )
}