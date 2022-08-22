resource "aws_s3_bucket" "thanos_storage" {
  bucket = "${var.prefix}-thanos-storage"

  tags = var.tags
}

resource "aws_s3_bucket_acl" "thanos_storage_acl" {
  bucket = aws_s3_bucket.thanos_storage.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_access_from_thanos_storage_gateway" {
  bucket = aws_s3_bucket.thanos_storage.id
  policy = data.aws_iam_policy_document.thanos_storage_s3_bucket_policy_document.json
}

data "aws_iam_policy_document" "thanos_storage_s3_bucket_policy_document" {
  statement {
    sid = "Stmt1660659393829"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.thanos_storage.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.thanos_storage.id}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"
      values   = [var.vpc_id]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
