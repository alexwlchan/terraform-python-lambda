provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
}

module "lambda" {
  source = "./lambda"

  name        = "clean-up-wc-assets-workingstorage-miro"
  module_name = "main"
  description = "A temporary Lambda created by Alex to help clean up s3://wellcomecollection-assets-workingstorage/miro"

  timeout = 600

  environment_variables = {
    QUEUE_URL = aws_sqs_queue.queue.url
  }

  filename = data.archive_file.lambda.output_path
}

resource "aws_sns_topic" "topic" {
  name = "clean-up-wc-assets-workingstorage-miro"
}

resource "aws_sqs_queue" "queue" {
  name = "clean-up-wc-assets-workingstorage-miro"
}

data "aws_iam_policy_document" "write_to_queue" {
  statement {
    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.queue.arn,
    ]
  }
}

data "aws_iam_policy_document" "s3_assets" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::wellcomecollection-assets-workingstorage/miro/*",
    ]
  }
}

resource "aws_iam_role_policy" "s3_editorial" {
  role = module.lambda.role_name
  policy = data.aws_iam_policy_document.s3_editorial.json
}

data "aws_iam_policy_document" "s3_editorial" {
  statement {
    actions = [
      "s3:Get*",
      "s3:Head*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::wellcomecollection-editorial-photography/*",
      "arn:aws:s3:::wellcomecollection-editorial-photography",
      "arn:aws:s3:::wellcomecollection-storage/miro/*",
    ]
  }
}

resource "aws_iam_role_policy" "s3_assets" {
  role = module.lambda.role_name
  policy = data.aws_iam_policy_document.s3_assets.json
}


resource "aws_iam_role_policy" "write_to_queue" {
  role = module.lambda.role_name
  policy = data.aws_iam_policy_document.write_to_queue.json
}

resource "aws_lambda_permission" "allow_sns_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
  depends_on    = [aws_sns_topic_subscription.topic_lambda]
}

resource "aws_sns_topic_subscription" "topic_lambda" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn
}
