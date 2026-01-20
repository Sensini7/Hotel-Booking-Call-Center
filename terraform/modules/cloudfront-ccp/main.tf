# CloudFront Origin Access Identity for S3 access
resource "aws_cloudfront_origin_access_identity" "ccp_oai" {
  comment = "OAI for CCP S3 bucket"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "ccp_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "SimpleAgentConsole.html"
  price_class         = var.price_class

  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = "S3-CCP-Hosting"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.ccp_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-CCP-Hosting"

    forwarded_values {
      query_string = true
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}
