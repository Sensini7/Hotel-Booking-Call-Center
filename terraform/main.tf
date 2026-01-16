provider "aws" {
  region = var.aws_region
}

# Data source to get the Connect instance
data "aws_connect_instance" "this" {
  instance_id = var.connect_instance_id
}

# Data source to get the Agent security profile
data "aws_connect_security_profile" "agent" {
  instance_id = var.connect_instance_id
  name        = "Agent"
}

# Hours of Operation
module "hours_of_operation" {
  source = "./modules/hours-of-operation"

  instance_id = var.connect_instance_id
  name        = "EmployeeBooking_DefaultHours"
  description = "Default hours of operation for Employee Booking service"
  time_zone   = "Africa/Lagos"

  config = [
    {
      day = "MONDAY"
      start_time = {
        hours   = 8
        minutes = 0
      }
      end_time = {
        hours   = 19
        minutes = 0
      }
    },
    {
      day = "TUESDAY"
      start_time = {
        hours   = 8
        minutes = 0
      }
      end_time = {
        hours   = 19
        minutes = 0
      }
    },
    {
      day = "WEDNESDAY"
      start_time = {
        hours   = 8
        minutes = 0
      }
      end_time = {
        hours   = 19
        minutes = 0
      }
    },
    {
      day = "THURSDAY"
      start_time = {
        hours   = 8
        minutes = 0
      }
      end_time = {
        hours   = 19
        minutes = 0
      }
    },
    {
      day = "FRIDAY"
      start_time = {
        hours   = 8
        minutes = 0
      }
      end_time = {
        hours   = 19
        minutes = 0
      }
    }
  ]

  tags = var.tags
}

# Queue: EmployeeBooking_Authenticated
module "queue_authenticated" {
  source = "./modules/queue"

  instance_id               = var.connect_instance_id
  name                      = "EmployeeBooking_Authenticated"
  description               = "Queue for authenticated employee bookings"
  hours_of_operation_id     = module.hours_of_operation.hours_of_operation_id
  outbound_caller_id_number = var.instance_phone_number_id

  tags = var.tags

  depends_on = [module.hours_of_operation]
}

# Queue: EmployeeBooking_Unknown
module "queue_unknown" {
  source = "./modules/queue"

  instance_id               = var.connect_instance_id
  name                      = "EmployeeBooking_Unknown"
  description               = "Queue for unknown employee bookings"
  hours_of_operation_id     = module.hours_of_operation.hours_of_operation_id
  outbound_caller_id_number = var.instance_phone_number_id

  tags = var.tags

  depends_on = [module.hours_of_operation]
}

# Routing Profile
module "routing_profile" {
  source = "./modules/routing-profile"

  instance_id               = var.connect_instance_id
  name                      = "EmployeeBooking_Default"
  description               = var.routing_profile_description
  default_outbound_queue_id = module.queue_unknown.queue_id
  voice_concurrency         = 1

  queue_configs = [
    {
      channel  = "VOICE"
      delay    = 0
      priority = 1
      queue_id = module.queue_authenticated.queue_id
    },
    {
      channel  = "VOICE"
      delay    = 0
      priority = 2
      queue_id = module.queue_unknown.queue_id
    }
  ]

  tags = var.tags

  depends_on = [
    module.queue_authenticated,
    module.queue_unknown
  ]
}

# User
module "user" {
  source = "./modules/user"

  instance_id                   = var.connect_instance_id
  username                      = var.user_username
  first_name                    = var.user_first_name
  last_name                     = var.user_last_name
  email                         = var.user_email
  phone_number                  = var.user_phone_number
  phone_country_code            = var.user_phone_country_code
  password                      = var.user_password
  routing_profile_id            = module.routing_profile.routing_profile_id
  security_profile_ids          = [data.aws_connect_security_profile.agent.security_profile_id]
  auto_accept                   = var.user_auto_accept
  after_contact_work_time_limit = 5

  tags = var.tags

  depends_on = [module.routing_profile]
}