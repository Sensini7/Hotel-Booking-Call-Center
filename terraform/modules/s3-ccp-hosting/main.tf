# S3 Bucket for CCP hosting
resource "aws_s3_bucket" "ccp_hosting" {
  bucket = var.bucket_name
  tags   = var.tags
}

# Block all public access (CloudFront will access via OAI)
resource "aws_s3_bucket_public_access_block" "ccp_hosting" {
  bucket = aws_s3_bucket.ccp_hosting.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}
