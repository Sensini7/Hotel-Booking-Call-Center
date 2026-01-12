output "hours_of_operation_id" {
  description = "The identifier of the hours of operation"
  value       = aws_connect_hours_of_operation.this.hours_of_operation_id
}

output "hours_of_operation_arn" {
  description = "The Amazon Resource Name (ARN) of the hours of operation"
  value       = aws_connect_hours_of_operation.this.arn
}
