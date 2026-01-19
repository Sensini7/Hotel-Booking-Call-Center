# Create a zip archive of the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function resource for SES email sending
resource "aws_lambda_function" "ses_email" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SENDER_EMAIL = var.sender_email
    }
  }

  tags = var.tags
}
