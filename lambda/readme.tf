data "aws_region" "current" {}

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

      log_group_name =replace(aws_cloudwatch_log_group.cloudwatch_log_group.name, "/", "$252")
    }
  )

  filename = "README.html"
}
