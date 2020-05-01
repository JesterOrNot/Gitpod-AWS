data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_eks_cluster_auth" "gitpod-cluster" {
  name = aws_eks_cluster.gitpod.name
}

data "aws_eks_cluster" "gitpod-cluster" {
  name       = aws_eks_cluster.gitpod.name
  depends_on = [aws_eks_cluster.gitpod]
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
