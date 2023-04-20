resource "aws_lambda_function" "lambda_function" {
  description   = var.description
  function_name = var.name

  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)

  role    = aws_iam_role.iam_role.arn
  handler = var.module_name == "" ? "${var.name}.main" : "${var.module_name}.main"
  runtime = "python3.9"
  timeout = var.timeout

  memory_size = var.memory_size

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  environment {
    variables = var.environment_variables
  }

  ephemeral_storage {
      size = 10240 # Min 512 MB and the Max 10240 MB
    }

  layers = ["arn:aws:lambda:eu-west-1:770693421928:layer:Klayers-p39-pillow:1"]
}
