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

# Lambda IAM Role for DynamoDB
module "lambda_role" {
  source = "./modules/lambda-role"

  policy_name = "Lambda_EmployeeBooking"
  role_name   = "Lambda_EmployeeBooking"
}

# Lambda IAM Role for SES
module "ses_lambda_role" {
  source = "./modules/ses-lambda-role"

  policy_name = "Lambda_EmployeeBooking_SES"
  role_name   = "Lambda_EmployeeBooking_SES"
}

# DynamoDB Table
module "dynamodb_table" {
  source = "./modules/dynamodb-table"

  table_name                    = var.dynamodb_table_name
  sample_employee_email         = var.employee_email
  sample_employee_name          = var.employee_name
  sample_employee_phone_number  = var.sample_employee_phone_number

  tags = var.tags
}

# Lambda Function for DB Lookup
module "lambda_function" {
  source = "./modules/lambda-function"

  function_name        = "EmployeeBooking_DBLookup"
  role_arn             = module.lambda_role.role_arn
  dynamodb_table_name  = var.dynamodb_table_name

  tags = var.tags

  depends_on = [
    module.lambda_role,
    module.dynamodb_table
  ]
}

# DynamoDB Table for Lex Hotel Bookings
module "lex_dynamodb_table" {
  source = "./modules/lex-dynamodb-table"

  table_name = "LexBookHotel"

  tags = var.tags
}

# Lambda Function for Lex Hotel Booking
module "lex_lambda_function" {
  source = "./modules/lex-lambda-function"

  function_name            = "EmployeeBooking_LexBookHotel"
  role_arn                 = module.lambda_role.role_arn
  lex_dynamodb_table_name  = "LexBookHotel"

  tags = var.tags

  depends_on = [
    module.lambda_role,
    module.lex_dynamodb_table
  ]
}

# Lambda Function for SES Email Confirmations
module "ses_lambda_function" {
  source = "./modules/ses-lambda-function"

  function_name  = "EmployeeBooking_SES"
  role_arn       = module.ses_lambda_role.role_arn
  sender_email   = var.ses_sender_email

  tags = var.tags

  depends_on = [module.ses_lambda_role]
}

# S3 Bucket for CCP Hosting
module "s3_ccp_hosting" {
  source = "./modules/s3-ccp-hosting"

  bucket_name = var.ccp_bucket_name

  tags = var.tags
}

# CloudFront Distribution for CCP
module "cloudfront_ccp" {
  source = "./modules/cloudfront-ccp"

  bucket_id                   = module.s3_ccp_hosting.bucket_id
  bucket_arn                  = module.s3_ccp_hosting.bucket_arn
  bucket_regional_domain_name = module.s3_ccp_hosting.bucket_domain_name

  tags = var.tags

  depends_on = [module.s3_ccp_hosting]
}

# S3 Bucket Policy for CloudFront OAI Access
resource "aws_s3_bucket_policy" "ccp_hosting" {
  bucket = module.s3_ccp_hosting.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = module.cloudfront_ccp.oai_arn
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_ccp_hosting.bucket_arn}/*"
      }
    ]
  })

  depends_on = [module.cloudfront_ccp]
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
