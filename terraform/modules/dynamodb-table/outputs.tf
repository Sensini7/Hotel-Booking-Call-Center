output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.employee.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.employee.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.employee.id
}

output "gsi_name" {
  description = "Name of the Global Secondary Index"
  value       = var.gsi_name
}
