# IAM Role for the EKS cluster

resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-ClusterRole"

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

  tags = var.tags
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
  name = "${var.prefix}-NodeGroupRole"

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

  tags = var.tags
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
  name               = "${var.prefix}-AWSLoadBalancerControllerRole"

  tags = var.tags
}

data "template_file" "aws_load_balancer_controller_iam_policy" {
  template = file("${path.module}/policies/aws_load_balancer_iam_policy.json")
}

resource "aws_iam_policy" "aws_load_balancer_controller_iam_policy" {
  name        = "${var.prefix}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM role policy for AWS Load balancer controller in EKS Cluster for ${var.prefix}"

  policy = data.template_file.aws_load_balancer_controller_iam_policy.rendered

  tags = var.tags
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
      values   = ["system:serviceaccount:external-dns:external-dns"]
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
  name        = "${var.prefix}-ExternalDNSIAMPolicy"
  path        = "/"
  description = "IAM role policy for External DNS pod in EKS Cluster for ${var.prefix}"

  policy = data.aws_iam_policy_document.route53_iam_policy.json

  tags = var.tags
}

resource "aws_iam_role" "external_dns" {
  name               = "${var.prefix}-ExternalDNSRole"
  assume_role_policy = data.aws_iam_policy_document.external_dns_role_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_dns_AmazonEKSExternalDNSIAMPolicy" {
  policy_arn = aws_iam_policy.external_dns_iam_policy.arn
  role       = aws_iam_role.external_dns.name
}

# IAM role for the AWS EFS CSI Driver

data "aws_iam_policy_document" "aws_efs_csi_driver_assume_role_policy" {
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
      values   = ["system:serviceaccount:kube-system:aws-efs-csi-driver"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_efs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.aws_efs_csi_driver_assume_role_policy.json
  name               = "${var.prefix}-AWSEFSCSIDriverRole"

  tags = var.tags
}

data "template_file" "aws_efs_csi_driver_iam_policy" {
  template = file("${path.module}/policies/aws_efs_csi_driver_iam_policy.json")
}

resource "aws_iam_policy" "aws_efs_csi_driver_iam_policy" {
  name        = "${var.prefix}-AWSEFSCSIDriverIAMPolicy"
  path        = "/"
  description = "IAM role policy for AWS EFS CSI Driver in EKS Cluster for ${var.prefix}"

  policy = data.template_file.aws_efs_csi_driver_iam_policy.rendered

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver_AWSEFSCSIDriverIAMPolicy" {
  policy_arn = aws_iam_policy.aws_efs_csi_driver_iam_policy.arn
  role       = aws_iam_role.aws_efs_csi_driver.name
}

# IAM role for the AWS Secrets Store CSI Driver

data "aws_iam_policy_document" "aws_secrets_store_csi_driver_assume_role_policy" {
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
      values   = ["system:serviceaccount:kube-system:aws-secrets-store-csi-driver"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_secrets_store_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.aws_secrets_store_csi_driver_assume_role_policy.json
  name               = "${var.prefix}-AWSSecretsCSIDriverRole"

  tags = var.tags
}

resource "aws_iam_policy" "aws_secrets_store_csi_driver_iam_policy" {
  name        = "${var.prefix}-AWSSecretsCSIDriverIAMPolicy"
  path        = "/"
  description = "IAM role policy for AWS Secrets Store CSI Driver in EKS Cluster for ${var.prefix}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
POLICY

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets_store_csi_driver_AWSSecretsCSIDriverIAMPolicy" {
  policy_arn = aws_iam_policy.aws_secrets_store_csi_driver_iam_policy.arn
  role       = aws_iam_role.aws_secrets_store_csi_driver.name
}


# IAM role for the thanos service account

data "aws_iam_policy_document" "thanos_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:monitoring:thanos-storegateway",
        "system:serviceaccount:monitoring:thanos-compactor",
        "system:serviceaccount:monitoring:kube-prometheus-stack-prometheus"
      ]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "thanos" {
  assume_role_policy = data.aws_iam_policy_document.thanos_assume_role_policy.json
  name               = "${var.prefix}-ThanosRole"

  tags = var.tags
}

resource "aws_iam_policy" "s3_bucket_access_policy" {
  name        = "thanos_s3_bucket_access_policy"
  path        = "/"
  description = "S3 bucket access policy for thanos in EKS Cluster for ${var.prefix}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "Statement",
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket",
              "s3:GetObject",
              "s3:DeleteObject",
              "s3:PutObject"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.thanos_storage.id}/*",
              "arn:aws:s3:::${aws_s3_bucket.thanos_storage.id}"
          ]
      }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "thanos_s3_bucket_access_policy" {
  policy_arn = aws_iam_policy.s3_bucket_access_policy.arn
  role       = aws_iam_role.thanos.name
}

# IAM role for Cloudwatch Exporter

data "aws_iam_policy_document" "cloudwatch_exporter_assume_role_policy" {
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
      values   = ["system:serviceaccount:monitoring:cloudwatch-exporter"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cloudwatch_exporter" {
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_exporter_assume_role_policy.json
  name               = "${var.prefix}-CloudwatchExporter"

  tags = var.tags
}

data "template_file" "cloudwatch_exporter_iam_policy" {
  template = file("${path.module}/policies/cloudwatch_exporter_iam_policy.json")
}

resource "aws_iam_policy" "cloudwatch_exporter_iam_policy" {
  name        = "${var.prefix}-CloudwatchExporterIAMPolicy"
  path        = "/"
  description = "IAM role policy for Cloudwatch Exporter in EKS Cluster for ${var.prefix}"

  policy = data.template_file.cloudwatch_exporter_iam_policy.rendered

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_exporter_IAMPolicy" {
  policy_arn = aws_iam_policy.cloudwatch_exporter_iam_policy.arn
  role       = aws_iam_role.cloudwatch_exporter.name
}
