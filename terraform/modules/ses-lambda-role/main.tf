# IAM Policy for Lambda with SES and CloudWatch Logs permissions
resource "aws_iam_policy" "lambda_ses_policy" {
  name        = var.policy_name
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for Lambda with Lambda service as trusted entity
resource "aws_iam_role" "lambda_ses_role" {
  name        = var.role_name
  description = "IAM role for Lambda SES function to send booking confirmation emails"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_ses_policy_attachment" {
  role       = aws_iam_role.lambda_ses_role.name
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
}
