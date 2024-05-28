output "api_gateway_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}
