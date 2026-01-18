# DynamoDB Table for Lex hotel bookings
resource "aws_dynamodb_table" "lex_book_hotel" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.partition_key

  attribute {
    name = var.partition_key
    type = "S"
  }

  tags = var.tags
}
