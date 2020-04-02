data "aws_availability_zones" "available" {
}

# To use EKS one needs a VPC or Virtual Private Cloud for base networking and this adds it
resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name"                                                 = var.kubernetes.vpc-name
    "kubernetes.io/cluster/${var.kubernetes.cluster-name}" = "shared"
  }
}

# This will route external traffic through internet gateway
resource "aws_subnet" "demo" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.demo.id

  tags = {
    "Name"                                                 = var.kubernetes.vpc-name
    "kubernetes.io/cluster/${var.kubernetes.cluster-name}" = "shared"
  }
}

# This is our Internet Gateway
resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "terraform-eks-demo"
  }
}

# Define  Routes
resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

# Associations for route table
resource "aws_route_table_association" "demo" {
  count = 2

  subnet_id      = aws_subnet.demo[count.index].id
  route_table_id = aws_route_table.demo.id
}

# Allow EKS to interact with AWS stuffs
resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attatchments
resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo-node.name
}

# Attatchments
resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.demo-node.name
}

# Networking Access to Kubernetes
resource "aws_security_group" "demo-cluster" {
  name        = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

# Allow me to Access Cluster from a workstation
resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  cidr_blocks       = ["34.82.79.165/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-cluster.id
  to_port           = 443
  type              = "ingress"
}

# The Kubernetes Cluster!
resource "aws_eks_cluster" "demo" {
  name     = var.kubernetes.cluster-name
  role_arn = aws_iam_role.demo-node.arn

  vpc_config {
    security_group_ids = [aws_security_group.demo-cluster.id]
    subnet_ids         = aws_subnet.demo.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy,
  ]
}
