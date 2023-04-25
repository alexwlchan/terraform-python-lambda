output "arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

output "role_arn" {
  description = "ARN of the IAM role for this Lambda"
  value       = aws_iam_role.iam_role.arn
}

output "role_name" {
  description = "Name of the IAM role for this Lambda"
  value       = aws_iam_role.iam_role.name
}

output "next_steps" {
  value = <<EOT
Your new function has been created!

For instructions on deploying new code, open ${local_file.readme.filename} in your browser
EOT
}
