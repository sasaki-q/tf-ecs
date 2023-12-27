resource "aws_subnet" "main" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = var.route_table_id
}
