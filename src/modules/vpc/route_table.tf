# Define  Routes
resource "aws_route_table" "application" {
  count  = var.subnet_count
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gitpod.*.id[count.index]
  }
}

resource "aws_route_table" "gitpod" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitpod.id
  }
}

# Associations for route table
resource "aws_route_table_association" "gitpod" {
  count = var.subnet_count

  subnet_id      = aws_subnet.gateway[count.index].id
  route_table_id = aws_route_table.gitpod.id
}

resource "aws_route_table_association" "application" {
  count = var.subnet_count
 
  subnet_id      = aws_subnet.application.*.id[count.index]
  route_table_id = aws_route_table.application.*.id[count.index]
}
