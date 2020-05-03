# Setup data source to get amazon-provided AMI for EKS nodes
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  name = "Worker"
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  tf-eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.gitpod.endpoint}' --b64-cluster-ca '${aws_eks_cluster.gitpod.certificate_authority.0.data}' '${var.kubernetes.cluster-name}'
USERDATA
}
 
resource "aws_launch_configuration" "tf_eks" {
  associate_public_ip_address = true
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks"
  security_groups             = ["${aws_security_group.gitpod-node.id}"]
  user_data_base64            = base64encode(local.tf-eks-node-userdata)
  key_name                    = var.keypair-name
 
  lifecycle {
    create_before_destroy = true
  }
}
# Kubernetes worker nodes
resource "aws_eks_node_group" "gitpod" {
  cluster_name    = aws_eks_cluster.gitpod.name
  node_group_name = "gitpod"
  node_role_arn   = aws_iam_role.gitpod-node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.gitpod-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.gitpod-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.gitpod-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
