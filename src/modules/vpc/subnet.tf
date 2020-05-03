# This will route external traffic through internet gateway
resource "aws_subnet" "gateway" {
  count = var.subnet_count
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.1${count.index}.0/24"
  vpc_id            = aws_vpc.vpc.id
}

# This will contain the Kubernetes cluster and in turn Gitpod
resource "aws_subnet" "application" {
  count = var.subnet_count
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.2${count.index}.0/24"
  vpc_id            = aws_vpc.vpc.id
}
