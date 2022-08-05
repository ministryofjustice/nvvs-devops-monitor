resource "aws_eks_cluster" "this" {
  count                     = var.create ? 1 : 0
  name                      = var.prefix
  role_arn                  = aws_iam_role.cluster[count.index].arn
  enabled_cluster_log_types = ["api", "audit"]

  vpc_config {
    subnet_ids = var.private_subnets
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]

  tags = var.tags
}

data "tls_certificate" "this" {
  count = var.create ? 1 : 0
  url   = aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count           = var.create ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[count.index].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this[count.index].identity[0].oidc[0].issuer
}
