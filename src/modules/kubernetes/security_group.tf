# Networking Access to Kubernetes
resource "aws_security_group" "gitpod-cluster" {
  name                   = "terraform-eks-gitpod-cluster"
  description            = "Cluster communication with worker nodes"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All trafic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-gitpod"
  }
}

resource "aws_security_group" "gitpod-node" {
  name                   = "terraform-eks-gitpod-node"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All trafic
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

resource "aws_security_group_rule" "tf-eks-node-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the Kubernetes nodes directly."
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.gitpod-cluster.id
  to_port           = 22
  type              = "ingress"
}

# Setup worker node security group

resource "aws_security_group_rule" "tf-eks-node-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.gitpod-cluster.id
  source_security_group_id = aws_security_group.gitpod-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "tf-eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.gitpod-cluster.id
  source_security_group_id = aws_security_group.gitpod-node.id
  to_port                  = 65535
  type                     = "ingress"
}

# allow worker nodes to access EKS master
resource "aws_security_group_rule" "tf-eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.gitpod-cluster.id
  source_security_group_id = aws_security_group.gitpod-node.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "tf-eks-node-ingress-master" {
  description              = "Allow cluster control to receive communication from the worker Kubelets"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.gitpod-node.id
  source_security_group_id = aws_security_group.gitpod-cluster.id
  to_port                  = 443
  type                     = "ingress"
}
