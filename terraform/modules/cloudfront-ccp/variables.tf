variable "bucket_id" {
  description = "ID of the S3 bucket for CloudFront origin"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  type        = string
}

variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags to apply to CloudFront distribution"
  type        = map(string)
  default     = {}
}
