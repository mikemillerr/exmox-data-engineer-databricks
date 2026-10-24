resource "aws_s3_bucket" "root" {
  bucket        = local.root_bucket_name
  force_destroy = var.root_bucket_force_destroy
}

resource "aws_s3_bucket_ownership_controls" "root" {
  bucket = aws_s3_bucket.root.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "root" {
  bucket = aws_s3_bucket.root.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root" {
  bucket = aws_s3_bucket.root.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "root" {
  bucket = aws_s3_bucket.root.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "databricks_aws_bucket_policy" "root" {
  provider = databricks.account
  bucket   = aws_s3_bucket.root.bucket
}

resource "aws_s3_bucket_policy" "root" {
  bucket = aws_s3_bucket.root.id
  policy = data.databricks_aws_bucket_policy.root.json

  depends_on = [aws_s3_bucket_public_access_block.root]
}
