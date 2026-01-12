resource "aws_connect_queue" "this" {
  instance_id           = var.instance_id
  name                  = var.name
  description           = var.description
  hours_of_operation_id = var.hours_of_operation_id

  dynamic "outbound_caller_config" {
    for_each = var.outbound_caller_id_number != null ? [1] : []
    content {
      outbound_caller_id_name      = var.outbound_caller_id_name != null ? var.outbound_caller_id_name : null
      outbound_caller_id_number_id = var.outbound_caller_id_number
    }
  }

  max_contacts = var.max_contacts
  status       = var.status

  tags = var.tags
}
