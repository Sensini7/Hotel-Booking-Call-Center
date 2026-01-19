output "function_name" {
  description = "Name of the SES Lambda function"
  value       = aws_lambda_function.ses_email.function_name
}

output "function_arn" {
  description = "ARN of the SES Lambda function"
  value       = aws_lambda_function.ses_email.arn
}

output "function_invoke_arn" {
  description = "Invoke ARN of the SES Lambda function"
  value       = aws_lambda_function.ses_email.invoke_arn
}

output "function_qualified_arn" {
  description = "Qualified ARN of the SES Lambda function"
  value       = aws_lambda_function.ses_email.qualified_arn
}

output "function_version" {
  description = "Latest published version of the SES Lambda function"
  value       = aws_lambda_function.ses_email.version
}
