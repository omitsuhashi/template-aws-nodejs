resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.rest_api_parent_id
  path_part   = var.path
}
