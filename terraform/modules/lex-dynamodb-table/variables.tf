variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "LexBookHotel"
}

variable "partition_key" {
  description = "Partition key name for the table"
  type        = string
  default     = "TripID"
}

variable "billing_mode" {
  description = "Billing mode for the DynamoDB table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "tags" {
  description = "Tags to apply to the DynamoDB table"
  type        = map(string)
  default     = {}
}
