resource "aws_connect_user" "this" {
  instance_id          = var.instance_id
  name                 = var.username
  password             = var.password
  routing_profile_id   = var.routing_profile_id
  security_profile_ids = var.security_profile_ids

  phone_config {
    phone_type                    = var.phone_type
    auto_accept                   = var.auto_accept
    after_contact_work_time_limit = var.after_contact_work_time_limit
    desk_phone_number             = var.phone_number != null ? var.phone_number : null
  }

  identity_info {
    email      = var.email
    first_name = var.first_name
    last_name  = var.last_name
  }

  tags = var.tags
}
