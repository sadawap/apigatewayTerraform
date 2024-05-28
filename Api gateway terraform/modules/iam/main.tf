resource "aws_iam_policy" "dynamodb_access" {
  name        = var.policy_name
  description = "IAM policy for Lambda to access DynamoDB"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Effect   = "Allow",
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

output "iam_policy_arn" {
  value = aws_iam_policy.dynamodb_access.arn
}
