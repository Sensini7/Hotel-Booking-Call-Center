variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "Employee"
}

variable "partition_key" {
  description = "Partition key name for the table"
  type        = string
  default     = "EmployeeID"
}

variable "gsi_name" {
  description = "Name of the Global Secondary Index"
  type        = string
  default     = "PhoneNumber-index"
}

variable "gsi_partition_key" {
  description = "Partition key for the Global Secondary Index"
  type        = string
  default     = "PhoneNumber"
}

variable "billing_mode" {
  description = "Billing mode for the DynamoDB table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "create_sample_item" {
  description = "Whether to create a sample employee item in the table"
  type        = bool
  default     = true
}

variable "sample_employee_id" {
  description = "Employee ID for the sample item"
  type        = string
  default     = "101"
}

variable "sample_employee_pin" {
  description = "Employee PIN for the sample item"
  type        = string
  default     = "111"
}

variable "sample_employee_email" {
  description = "Email address for the sample employee"
  type        = string
  default     = "peleke@gmail.com"
}

variable "sample_employee_name" {
  description = "Name for the sample employee"
  type        = string
  default     = "peleke"
}

variable "sample_employee_phone_number" {
  description = "Phone number for the sample employee in E.164 format"
  type        = string
  default     = "+18285282177"
}

variable "tags" {
  description = "Tags to apply to the DynamoDB table"
  type        = map(string)
  default     = {}
}
