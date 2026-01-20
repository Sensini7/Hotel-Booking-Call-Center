output "hours_of_operation_id" {
  description = "The identifier of the hours of operation"
  value       = module.hours_of_operation.hours_of_operation_id
}

output "queue_authenticated_id" {
  description = "The identifier of the authenticated queue"
  value       = module.queue_authenticated.queue_id
}

output "queue_unknown_id" {
  description = "The identifier of the unknown queue"
  value       = module.queue_unknown.queue_id
}

output "routing_profile_id" {
  description = "The identifier of the routing profile"
  value       = module.routing_profile.routing_profile_id
}

output "user_id" {
  description = "The identifier of the user"
  value       = module.user.user_id
}

output "user_arn" {
  description = "The ARN of the user"
  value       = module.user.user_arn
}

output "lambda_role_arn" {
  description = "The ARN of the Lambda IAM role"
  value       = module.lambda_role.role_arn
}

output "lambda_role_name" {
  description = "The name of the Lambda IAM role"
  value       = module.lambda_role.role_name
}

output "lambda_policy_arn" {
  description = "The ARN of the Lambda IAM policy"
  value       = module.lambda_role.policy_arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB Employee table"
  value       = module.dynamodb_table.table_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB Employee table"
  value       = module.dynamodb_table.table_arn
}

output "dynamodb_gsi_name" {
  description = "The name of the DynamoDB PhoneNumber GSI"
  value       = module.dynamodb_table.gsi_name
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda_function.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.lambda_function.function_arn
}

output "lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = module.lambda_function.function_invoke_arn
}

output "lex_dynamodb_table_name" {
  description = "The name of the Lex hotel bookings DynamoDB table"
  value       = module.lex_dynamodb_table.table_name
}

output "lex_dynamodb_table_arn" {
  description = "The ARN of the Lex hotel bookings DynamoDB table"
  value       = module.lex_dynamodb_table.table_arn
}

output "lex_lambda_function_name" {
  description = "The name of the Lex Lambda function"
  value       = module.lex_lambda_function.function_name
}

output "lex_lambda_function_arn" {
  description = "The ARN of the Lex Lambda function"
  value       = module.lex_lambda_function.function_arn
}

output "lex_lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lex Lambda function"
  value       = module.lex_lambda_function.function_invoke_arn
}

output "ses_lambda_role_arn" {
  description = "The ARN of the SES Lambda IAM role"
  value       = module.ses_lambda_role.role_arn
}

output "ses_lambda_role_name" {
  description = "The name of the SES Lambda IAM role"
  value       = module.ses_lambda_role.role_name
}

output "ses_lambda_policy_arn" {
  description = "The ARN of the SES Lambda IAM policy"
  value       = module.ses_lambda_role.policy_arn
}

output "ses_lambda_function_name" {
  description = "The name of the SES Lambda function"
  value       = module.ses_lambda_function.function_name
}

output "ses_lambda_function_arn" {
  description = "The ARN of the SES Lambda function"
  value       = module.ses_lambda_function.function_arn
}

output "ses_lambda_function_invoke_arn" {
  description = "The invoke ARN of the SES Lambda function"
  value       = module.ses_lambda_function.function_invoke_arn
}

# CCP Hosting Outputs
output "ccp_s3_bucket_name" {
  description = "The name of the S3 bucket hosting the CCP"
  value       = module.s3_ccp_hosting.bucket_id
}

output "ccp_s3_bucket_arn" {
  description = "The ARN of the S3 bucket hosting the CCP"
  value       = module.s3_ccp_hosting.bucket_arn
}

output "ccp_cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution for CCP"
  value       = module.cloudfront_ccp.cloudfront_distribution_id
}

output "ccp_cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution for CCP"
  value       = module.cloudfront_ccp.cloudfront_domain_name
}

output "ccp_cloudfront_url" {
  description = "The full HTTPS URL of the CloudFront distribution for CCP"
  value       = module.cloudfront_ccp.cloudfront_url
}
