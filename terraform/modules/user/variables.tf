variable "instance_id" {
  description = "The identifier of the Amazon Connect instance"
  type        = string
}

variable "username" {
  description = "The login username for the user (must follow email format or contain only: a-z, A-Z, 0-9, _, -, +, .)"
  type        = string
}

variable "first_name" {
  description = "The first name of the user"
  type        = string
}

variable "last_name" {
  description = "The last name of the user"
  type        = string
}

variable "email" {
  description = "The email address of the user"
  type        = string
}

variable "phone_number" {
  description = "The phone number of the user"
  type        = string
  default     = null
}

variable "phone_country_code" {
  description = "The country code for the phone number (e.g., US)"
  type        = string
  default     = "US"
}

variable "password" {
  description = "The password for the user"
  type        = string
  sensitive   = true
}

variable "routing_profile_id" {
  description = "The identifier of the routing profile for the user"
  type        = string
}

variable "security_profile_ids" {
  description = "The identifiers of the security profiles for the user"
  type        = list(string)
}

variable "phone_type" {
  description = "The phone type for the user"
  type        = string
  default     = "SOFT_PHONE"
}

variable "auto_accept" {
  description = "Whether to auto-accept calls"
  type        = bool
  default     = false
}

variable "after_contact_work_time_limit" {
  description = "The after contact work time limit in seconds"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags to apply to the user"
  type        = map(string)
  default     = {}
}
