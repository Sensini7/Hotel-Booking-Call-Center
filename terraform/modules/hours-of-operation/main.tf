resource "aws_connect_hours_of_operation" "this" {
  instance_id = var.instance_id
  name        = var.name
  description = var.description
  time_zone   = var.time_zone

  dynamic "config" {
    for_each = var.config
    content {
      day = config.value.day
      
      dynamic "end_time" {
        for_each = config.value.end_time != null ? [config.value.end_time] : []
        content {
          hours   = end_time.value.hours
          minutes = end_time.value.minutes
        }
      }
      
      dynamic "start_time" {
        for_each = config.value.start_time != null ? [config.value.start_time] : []
        content {
          hours   = start_time.value.hours
          minutes = start_time.value.minutes
        }
      }
    }
  }

  tags = var.tags
}
