# The Kubernetes Cluster!
resource "aws_eks_cluster" "gitpod" {
  name     = var.kubernetes.cluster-name
  role_arn = aws_iam_role.gitpod-cluster.arn

  vpc_config {
    endpoint_public_access = true
    security_group_ids     = [aws_security_group.gitpod-cluster.id]
    subnet_ids             = var.subnet_ids
  }

  provisioner "local-exec" {
    command     = file("files/bootstrap.sh")
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSServicePolicy,
  ]
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
