variable "policy_name" {
  description = "Name of the IAM policy for Lambda SES"
  type        = string
  default     = "Lambda_EmployeeBooking_SES"
}

variable "role_name" {
  description = "Name of the IAM role for Lambda SES"
  type        = string
  default     = "Lambda_EmployeeBooking_SES"
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Lambda_EmployeeBooking_SES"
}
