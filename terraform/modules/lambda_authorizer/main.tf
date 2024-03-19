data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.source_path}/authorizer"
  output_path = "${var.source_path}/authorizer.zip"
}

resource "aws_cognito_identity_pool" "id_pool" {
  identity_pool_name               = var.name
  allow_unauthenticated_identities = false
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${var.name}_authorizer"
  role             = var.role_arn
  handler          = "index.authorizerHandler"
  runtime          = var.runtime
  source_code_hash = filebase64sha256("${var.source_path}/authorizer/index.js")
  memory_size      = 128
  filename         = data.archive_file.lambda_zip.output_path
  architectures    = ["arm64"]
  environment {
    variables = {
      COGNITO_IDENTITY_POOL_ID = aws_cognito_identity_pool.id_pool.id
    }
  }
  layers = var.layers
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name           = var.name
  rest_api_id    = var.rest_api_id
  authorizer_uri = aws_lambda_function.lambda.invoke_arn
}
