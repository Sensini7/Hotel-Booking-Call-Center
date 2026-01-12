variable "aws_region" {
  description = "AWS region where the Connect instance is located"
  type        = string
  default     = "us-east-1"
}

variable "connect_instance_id" {
  description = "The identifier of the Amazon Connect instance"
  type        = string
}

variable "instance_phone_number_id" {
  description = "The phone number ID associated with the Connect instance (ARN or ID)"
  type        = string
}

variable "routing_profile_description" {
  description = "Description for the routing profile"
  type        = string
  default     = "Default routing profile for Employee Booking service"
}

variable "user_first_name" {
  description = "First name of the user"
  type        = string
  default     = "Peleke"
}

variable "user_last_name" {
  description = "Last name of the user"
  type        = string
  default     = "Ngaih"
}

variable "user_email" {
  description = "Email address of the user"
  type        = string
  default     = "pelekengaih@gmail.com"
}

variable "user_phone_number" {
  description = "Phone number of the user (optional)"
  type        = string
  default     = null
}

variable "user_password" {
  description = "Password for the user"
  type        = string
  sensitive   = true
}

variable "user_auto_accept" {
  description = "Whether to auto-accept calls for the user"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
