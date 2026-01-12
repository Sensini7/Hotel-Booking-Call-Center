variable "instance_id" {
  description = "The identifier of the Amazon Connect instance"
  type        = string
}

variable "name" {
  description = "The name of the routing profile"
  type        = string
}

variable "description" {
  description = "The description of the routing profile"
  type        = string
  default     = ""
}

variable "default_outbound_queue_id" {
  description = "The default outbound queue ID"
  type        = string
}

variable "voice_concurrency" {
  description = "The concurrency for voice channel"
  type        = number
  default     = 1
}

variable "queue_configs" {
  description = "One or more queue config blocks"
  type = list(object({
    channel  = string
    delay    = number
    priority = number
    queue_id = string
  }))
}

variable "tags" {
  description = "Tags to apply to the routing profile"
  type        = map(string)
  default     = {}
}
