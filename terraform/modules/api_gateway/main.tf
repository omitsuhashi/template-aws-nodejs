
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_name
  description = var.description
}

resource "aws_api_gateway_resource" "root_api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = var.root_path
}
