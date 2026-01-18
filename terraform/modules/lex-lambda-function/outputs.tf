output "function_name" {
  description = "Name of the Lex Lambda function"
  value       = aws_lambda_function.lex_book_hotel.function_name
}

output "function_arn" {
  description = "ARN of the Lex Lambda function"
  value       = aws_lambda_function.lex_book_hotel.arn
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lex Lambda function"
  value       = aws_lambda_function.lex_book_hotel.invoke_arn
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lex Lambda function"
  value       = aws_lambda_function.lex_book_hotel.qualified_arn
}

output "function_version" {
  description = "Latest published version of the Lex Lambda function"
  value       = aws_lambda_function.lex_book_hotel.version
}
