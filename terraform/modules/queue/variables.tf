variable "instance_id" {
  description = "The identifier of the Amazon Connect instance"
  type        = string
}

variable "name" {
  description = "The name of the queue"
  type        = string
}

variable "description" {
  description = "The description of the queue"
  type        = string
  default     = ""
}

variable "hours_of_operation_id" {
  description = "The identifier for the hours of operation"
  type        = string
}

variable "outbound_caller_id_number" {
  description = "The phone number ID to use as the outbound caller ID number"
  type        = string
  default     = null
}

variable "outbound_caller_id_name" {
  description = "The name to use as the outbound caller ID name"
  type        = string
  default     = null
}

variable "max_contacts" {
  description = "The maximum number of contacts that can be in the queue before it is considered full"
  type        = number
  default     = null
}

variable "status" {
  description = "The status of the queue"
  type        = string
  default     = "ENABLED"
}

variable "tags" {
  description = "Tags to apply to the queue"
  type        = map(string)
  default     = {}
}
