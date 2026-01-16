# DynamoDB Table for Employee data
resource "aws_dynamodb_table" "employee" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.partition_key

  attribute {
    name = var.partition_key
    type = "S"
  }

  attribute {
    name = var.gsi_partition_key
    type = "S"
  }

  # Global Secondary Index for PhoneNumber lookup
  global_secondary_index {
    name            = var.gsi_name
    hash_key        = var.gsi_partition_key
    projection_type = "ALL"
  }

  tags = var.tags
}

# Sample employee item
resource "aws_dynamodb_table_item" "sample_employee" {
  count      = var.create_sample_item ? 1 : 0
  table_name = aws_dynamodb_table.employee.name
  hash_key   = aws_dynamodb_table.employee.hash_key

  item = jsonencode({
    EmployeeID = {
      S = var.sample_employee_id
    }
    EmployeePIN = {
      S = var.sample_employee_pin
    }
    EmailAddress = {
      S = var.sample_employee_email
    }
    EmployeeName = {
      S = var.sample_employee_name
    }
    PhoneNumber = {
      S = var.sample_employee_phone
    }
  })
}
