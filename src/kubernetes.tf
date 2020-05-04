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
  cidr_blocks       = ["0.0.0.0/0"]
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
  role_arn = aws_iam_role.gitpod-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.gitpod-cluster.id]
    subnet_ids         = aws_subnet.gitpod[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSServicePolicy,
  ]
}
