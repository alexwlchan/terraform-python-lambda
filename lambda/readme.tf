data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # the caller identity ARN will be something like:
  #
  #     arn:aws:sts::760097843905:assumed-role/platform-admin/aws-go-sdk-1682420875336428000-dev
  #
  account_name = split("-", split("/", data.aws_caller_identity.current.arn)[1])[0]
}

resource "local_file" "readme" {
  content = templatefile(
    "${path.module}/README.html.tpl",
    {
      name = var.name
      region = data.aws_region.current.name

      topic_arn = aws_sns_topic.input.arn
      topic_name = aws_sns_topic.input.name

      queue_url = aws_sqs_queue.output.url
      queue_arn = aws_sqs_queue.output.arn
      queue_name = aws_sqs_queue.output.name

      account_name = local.account_name

      log_group_name =aws_cloudwatch_log_group.cloudwatch_log_group.name
    }
  )

  filename = "README.html"
}
