resource "aws_eks_node_group" "green" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "green"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = var.tags
}
