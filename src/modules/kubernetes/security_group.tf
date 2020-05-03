# Networking Access to Kubernetes
resource "aws_security_group" "gitpod-cluster" {
  name                   = "terraform-eks-gitpod-cluster"
  description            = "Cluster communication with worker nodes"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

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
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.gitpod-cluster.id
  to_port           = 443
  type              = "ingress"
}
