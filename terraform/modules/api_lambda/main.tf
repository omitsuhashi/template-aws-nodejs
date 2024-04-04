data "archive_file" "lambda_zip" {
  type             = "zip"
  source_dir       = "${var.source_path}/${var.function_name}/"
  output_file_mode = "0666"
  output_path      = "${var.source_path}/${var.function_name}.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  role             = var.role_arn
  handler          = "index.apiHandler"
  runtime          = var.runtime
  source_code_hash = filebase64sha256("${var.source_path}/${var.function_name}/index.js")
  memory_size      = var.memory_size
  filename         = data.archive_file.lambda_zip.output_path
  architectures    = ["arm64"]
  environment {
    variables = merge(var.environment, { "DATABASE_URL" = var.database_url })
  }
  layers = var.layers
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.rest_api_resource_id
  http_method   = var.api_method
  authorization = var.authorizer_id == null ? "NONE" : "CUSTOM"
  authorizer_id = var.authorizer_id
  # ISSUE 認証は必要なので対応する
}

resource "aws_api_gateway_integration" "api_get_lambda" {
  rest_api_id             = var.rest_api_id
  resource_id             = var.rest_api_resource_id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST" # Lambda用
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}
