variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "EmployeeBooking_LexBookHotel"
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Timeout in seconds for the Lambda function"
  type        = number
  default     = 7
}

variable "role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  type        = string
}

variable "lex_dynamodb_table_name" {
  description = "Name of the DynamoDB table for Lex hotel bookings"
  type        = string
  default     = "LexBookHotel"
}

variable "tags" {
  description = "Tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}
