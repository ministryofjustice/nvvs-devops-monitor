resource "aws_s3_bucket" "thanos_storage" {
  bucket = "${var.prefix}-thanos-storage"

  tags = var.tags
}

resource "aws_s3_bucket_acl" "thanos_storage_acl" {
  bucket     = aws_s3_bucket.thanos_storage.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
# AWS Reference https://aws.amazon.com/blogs/aws/heads-up-amazon-s3-security-changes-are-coming-in-april-of-2023/
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.thanos_storage.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "thanos_storage_public_block" {
  bucket = aws_s3_bucket.thanos_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
