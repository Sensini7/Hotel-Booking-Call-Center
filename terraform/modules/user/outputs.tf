output "user_id" {
  description = "The identifier of the user"
  value       = aws_connect_user.this.user_id
}

output "user_arn" {
  description = "The Amazon Resource Name (ARN) of the user"
  value       = aws_connect_user.this.arn
}
