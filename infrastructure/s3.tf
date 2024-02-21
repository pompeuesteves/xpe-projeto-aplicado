resource "aws_s3_bucket" "buckets" {
  count  = length(var.bucket_names)
  bucket = "${var.prefix}-${var.bucket_names[count.index]}-${var.account}-tf"

  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = length(var.bucket_names)
  bucket = aws_s3_bucket.buckets[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "this" {
  count  = length(var.bucket_names)
  bucket = aws_s3_bucket.buckets[count.index].id

  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = length(var.bucket_names)
  bucket = aws_s3_bucket.buckets[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}