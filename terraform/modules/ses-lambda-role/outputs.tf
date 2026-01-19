output "role_arn" {
  description = "ARN of the Lambda SES IAM role"
  value       = aws_iam_role.lambda_ses_role.arn
}

output "role_name" {
  description = "Name of the Lambda SES IAM role"
  value       = aws_iam_role.lambda_ses_role.name
}

output "policy_arn" {
  description = "ARN of the Lambda SES IAM policy"
  value       = aws_iam_policy.lambda_ses_policy.arn
}

output "policy_name" {
  description = "Name of the Lambda SES IAM policy"
  value       = aws_iam_policy.lambda_ses_policy.name
}
