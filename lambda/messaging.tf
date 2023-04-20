resource "aws_sns_topic" "input" {
  name = "${var.name}-input"
}

resource "aws_lambda_permission" "allow_sns_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.input.arn
  depends_on    = [aws_sns_topic_subscription.input_to_lambda]
}

resource "aws_sns_topic_subscription" "input_to_lambda" {
  topic_arn = aws_sns_topic.input.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_function.arn
}

resource "aws_sqs_queue" "output" {
  name = "${var.name}-output"
}

data "aws_iam_policy_document" "write_to_output_queue" {
  statement {
    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.output.arn,
    ]
  }
}

resource "aws_iam_role_policy" "write_to_output_queue" {
  role   = aws_iam_role.iam_role.name
  policy = data.aws_iam_policy_document.write_to_output_queue.json
}
