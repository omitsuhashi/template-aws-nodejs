output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api_gateway.id
}

output "api_root_id" {
  value = aws_api_gateway_resource.root_api.id
}
