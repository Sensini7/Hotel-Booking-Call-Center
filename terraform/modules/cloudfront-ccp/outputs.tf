output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.ccp_distribution.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.ccp_distribution.domain_name
}

output "cloudfront_url" {
  description = "Full HTTPS URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.ccp_distribution.domain_name}"
}

output "oai_arn" {
  description = "ARN of the CloudFront Origin Access Identity"
  value       = aws_cloudfront_origin_access_identity.ccp_oai.iam_arn
}

output "oai_path" {
  description = "CloudFront access identity path"
  value       = aws_cloudfront_origin_access_identity.ccp_oai.cloudfront_access_identity_path
}
