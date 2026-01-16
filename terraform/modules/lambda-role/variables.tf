variable "policy_name" {
  description = "Name of the IAM policy for Lambda"
  type        = string
  default     = "Lambda_EmployeeBooking"
}

variable "role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
  default     = "Lambda_EmployeeBooking"
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Policy for Lambda function to access DynamoDB and CloudWatch Logs for Employee Booking"
}
