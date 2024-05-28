resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_get_arn
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_post_arn
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [aws_api_gateway_integration.get_integration, aws_api_gateway_integration.post_integration]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.stage_name
}

resource "aws_api_gateway_method_response" "cors_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "*"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "*"
  status_code = aws_api_gateway_method_response.cors_response.status_code
  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'*'"
  }
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}
