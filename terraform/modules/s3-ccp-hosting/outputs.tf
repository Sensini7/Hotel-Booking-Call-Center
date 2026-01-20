output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.ccp_hosting.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.ccp_hosting.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.ccp_hosting.bucket_regional_domain_name
}
