resource "aws_s3_bucket" "thanos_storage" {
  count  = var.create ? 1 : 0
  bucket = "${var.prefix}-thanos-storage"

  tags = var.tags
}

resource "aws_s3_bucket_acl" "thanos_storage_acl" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.thanos_storage[count.index].id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_access_from_thanos_storage_gateway" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.thanos_storage[count.index].id
  policy = data.aws_iam_policy_document.thanos_storage_s3_bucket_policy_document[count.index].json
}

data "aws_iam_policy_document" "thanos_storage_s3_bucket_policy_document" {
  count = var.create ? 1 : 0
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
      "arn:aws:s3:::${aws_s3_bucket.thanos_storage[count.index].id}/*",
      "arn:aws:s3:::${aws_s3_bucket.thanos_storage[count.index].id}"
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
