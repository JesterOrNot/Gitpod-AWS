# To use EKS one needs a VPC or Virtual Private Cloud for base networking and this adds it.
resource "aws_vpc" "gitpod" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name"                                                 = var.kubernetes.vpc-name
    "kubernetes.io/cluster/${var.kubernetes.cluster-name}" = "shared"
  }
}

# This will route external traffic through internet gateway
resource "aws_subnet" "gitpod" {
  count = 2
  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.gitpod.id

  tags = map(
    "Name", var.kubernetes.vpc-name,
    "kubernetes.io/cluster/${var.kubernetes.cluster-name}", "shared",
  )
}

# This is our Internet Gateway
resource "aws_internet_gateway" "gitpod" {
  vpc_id = aws_vpc.gitpod.id

  tags = {
    Name = "terraform-eks-gitpod"
  }
}

# Define  Routes
resource "aws_route_table" "gitpod" {
  vpc_id = aws_vpc.gitpod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitpod.id
  }
}

# Associations for route table
resource "aws_route_table_association" "gitpod" {
  count = 2

  subnet_id      = aws_subnet.gitpod.*.id[count.index]
  route_table_id = aws_route_table.gitpod.id
}
