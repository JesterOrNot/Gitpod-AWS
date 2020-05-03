# This will provide a static IP for our server
resource "aws_eip" "nat_gateway" {
  count = var.subnet_count
  vpc   = true
}
