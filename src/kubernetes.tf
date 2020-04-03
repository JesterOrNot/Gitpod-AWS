# Get all available zones
data "aws_availability_zones" "available" {}

# To use EKS one needs a VPC or Virtual Private Cloud for base networking and this adds it
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

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.gitpod.id

  tags = {
    "Name"                                                 = var.kubernetes.vpc-name
    "kubernetes.io/cluster/${var.kubernetes.cluster-name}" = "shared"
  }
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

  subnet_id      = aws_subnet.gitpod[count.index].id
  route_table_id = aws_route_table.gitpod.id
}

# Allow EKS to interact with AWS stuffs
resource "aws_iam_role" "gitpod-node" {
  name = "terraform-eks-gitpod-cluster"

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
resource "aws_iam_role_policy_attachment" "gitpod-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.gitpod-node.name
}

# Attatchments
resource "aws_iam_role_policy_attachment" "gitpod-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.gitpod-node.name
}

# Networking Access to Kubernetes
resource "aws_security_group" "gitpod-cluster" {
  name        = "terraform-eks-gitpod-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.gitpod.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-gitpod"
  }
}

# Allow me to Access Cluster from a workstation
resource "aws_security_group_rule" "gitpod-cluster-ingress-workstation-https" {
  cidr_blocks       = ["34.82.79.165/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.gitpod-cluster.id
  to_port           = 443
  type              = "ingress"
}

# The Kubernetes Cluster!
resource "aws_eks_cluster" "gitpod" {
  name     = var.kubernetes.cluster-name
  role_arn = aws_iam_role.gitpod-node.arn
  
  # Install Gitpod!
  provisioner "local-exec" {
      command = <<END
      ./scripts/deps.sh \
      && helm repo add charts.gitpod.io https://charts.gitpod.io \
      && helm dep update \
      && helm upgrade --install $(for i in $(cat configuration.txt); do echo -e \"-f $i\"; done) gitpod .
      END
  }

  vpc_config {
    security_group_ids = [aws_security_group.gitpod-cluster.id]
    subnet_ids         = aws_subnet.gitpod.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSServicePolicy,
  ]
}
