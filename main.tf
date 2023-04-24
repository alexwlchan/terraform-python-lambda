provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}

module "lambda" {
  source = "./lambda"

  runtime = "python3.10"

  name        = "example-lambda-function"
  module_name = "main"
  description = "A Lambda function created to demo this module"

  timeout = 600

  source_dir = "${path.module}/src"
}

output "next_steps" {
  value = <<EOT
Your new function has been created!

For instructions on deploying new code, open ${module.lambda.readme_path} in your browser
EOT
}

resource "aws_iam_role_policy" "s3_editorial" {
  role   = module.lambda.role_name
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
