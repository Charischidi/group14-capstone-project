resource "aws_s3_bucket" "s3-buck" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket-control" {
  bucket = aws_s3_bucket.s3-buck.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket-control]

  bucket = aws_s3_bucket.s3-buck.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3-buck-versioning" {
  bucket = aws_s3_bucket.s3-buck.id
  versioning_configuration {
    status = "Enabled"
  }
}