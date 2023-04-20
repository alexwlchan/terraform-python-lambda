provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}

module "lambda" {
  source = "./lambda"

  runtime = "python3.9"

  name        = "clean-up-wc-assets-workingstorage-miro"
  module_name = "main"
  description = "A temporary Lambda created by Alex to help clean up s3://wellcomecollection-assets-workingstorage/miro"

  timeout = 600

  source_dir = "${path.module}/src"
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

resource "aws_iam_role_policy" "s3_assets" {
  role   = module.lambda.role_name
  policy = data.aws_iam_policy_document.s3_assets.json
}
