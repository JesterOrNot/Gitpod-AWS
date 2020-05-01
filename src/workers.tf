resource "aws_eks_node_group" "gitpod" {
  cluster_name    = aws_eks_cluster.gitpod.name
  node_group_name = "gitpod"
  node_role_arn   = aws_iam_role.gitpod-node.arn
  subnet_ids      = aws_subnet.gitpod[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.gitpod-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.gitpod-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.gitpod-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
