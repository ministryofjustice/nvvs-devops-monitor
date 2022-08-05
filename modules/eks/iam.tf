# IAM Role for the EKS cluster

resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-cluster"

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

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# IAM Role for cluster node group

resource "aws_iam_role" "node_group" {
  name = "${var.prefix}-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# IAM role for AWS Load Balancer Controller

data "aws_iam_policy_document" "aws_load_balancer_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_assume_role_policy.json
  name               = "AmazonEKSLoadBalancerControllerRole"
}

data "template_file" "aws_load_balancer_controller_iam_policy" {
  template = file("${path.module}/policies/aws_load_balancer_iam_policy.json")
}

resource "aws_iam_policy" "aws_load_balancer_controller_iam_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM role policy for AWS Load balancer controller"

  policy = data.template_file.aws_load_balancer_controller_iam_policy.rendered
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller_AWSLoadBalancerControllerIAMPolicy" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller_iam_policy.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
}

# IAM Role for external-dns with route53 iam policy

data "aws_iam_policy_document" "external_dns_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:external-dns"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "route53_iam_policy" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]
    effect  = "Allow"

    resources = [
      "arn:aws:route53:::hostedzone/*",
    ]
  }
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "external_dns_iam_policy" {
  name        = "ExternalDNSIAMPolicy"
  path        = "/"
  description = "IAM role policy for External DNS pod"

  policy = data.aws_iam_policy_document.route53_iam_policy.json
}

resource "aws_iam_role" "external_dns" {
  name               = "AmazonEKSExternalDNSRole"
  assume_role_policy = data.aws_iam_policy_document.external_dns_role_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_dns_AmazonEKSExternalDNSIAMPolicy" {
  policy_arn = aws_iam_policy.external_dns_iam_policy.arn
  role       = aws_iam_role.external_dns.name
}
