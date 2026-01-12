variable "instance_id" {
  description = "The identifier of the Amazon Connect instance"
  type        = string
}

variable "name" {
  description = "The name of the hours of operation"
  type        = string
}

variable "description" {
  description = "The description of the hours of operation"
  type        = string
  default     = ""
}

variable "time_zone" {
  description = "The time zone of the hours of operation"
  type        = string
}

variable "config" {
  description = "One or more config blocks"
  type = list(object({
    day       = string
    start_time = object({
      hours   = number
      minutes = number
    })
    end_time = object({
      hours   = number
      minutes = number
    })
  }))
}

variable "tags" {
  description = "Tags to apply to the hours of operation"
  type        = map(string)
  default     = {}
}
