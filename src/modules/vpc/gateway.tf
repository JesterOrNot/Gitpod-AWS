# This is our Internet Gateway
resource "aws_internet_gateway" "gitpod" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-eks-gitpod"
  }
}

resource "aws_nat_gateway" "gitpod" {
  count         = var.subnet_count
  allocation_id = aws_eip.nat_gateway.*.id[count.index]
  subnet_id     = aws_subnet.gateway.*.id[count.index]
  depends_on = [
    aws_internet_gateway.gitpod
  ]
}
