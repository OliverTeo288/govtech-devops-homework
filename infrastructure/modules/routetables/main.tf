### IGW

resource "aws_internet_gateway" "hw_igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "hw-igw"
  }
}

### EIP for NAT

resource "aws_eip" "hw_eip_a" {

  depends_on = [aws_internet_gateway.hw_igw]

  tags = {
    Name = "hw-eip-a"
  }

}

### NAT Gateway

resource "aws_nat_gateway" "hw_nat_a" {

  connectivity_type = "public"
  allocation_id     = aws_eip.hw_eip_a.id
  subnet_id         = var.public_subnet_a_id

  tags = {
    Name = "hw-nat-a"
  }

}

### Route tables

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = var.main_route_table_id

  tags = {
    Name = "hw-default-rt"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hw_igw.id
  }
  tags = {
    Name = "hw-public-rt"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.hw_nat_a.id
  }
  tags = {
    Name = "hw-private-rt"
  }
}

resource "aws_route_table_association" "public_subnet_a_public_route_table_association" {
  subnet_id      = var.public_subnet_a_id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_public_route_table_association" {
  subnet_id      = var.public_subnet_b_id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "app_subnet_a_private_route_table_association" {
  subnet_id      = var.app_subnet_a_id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "app_subnet_b_private_route_table_association" {
  subnet_id      = var.app_subnet_b_id
  route_table_id = aws_route_table.private_route_table.id
}
