data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.source_path}/authorizer"
  output_path = "${var.source_path}/authorizer.zip"
}

data "aws_ssm_parameter" "providers" {
  name = "${terraform.workspace}/providers"
}

resource "aws_lambda_function" "authorizer" {
  function_name    = "${var.name}_authorizer"
  role             = var.role_arn
  handler          = "index.authorizerHandler"
  runtime          = var.runtime
  source_code_hash = filebase64sha256("${var.source_path}/authorizer/index.js")
  memory_size      = 128
  filename         = data.archive_file.lambda_zip.output_path
  architectures    = ["arm64"]
  environment {
  }
  layers = var.layers
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "${var.name}_authorizer"
  rest_api_id            = var.rest_api_id
  authorizer_uri         = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "api_gateway_auth_invocation"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.authorizer.arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "${var.name}_authorizer_invocation_policy"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "demo-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
