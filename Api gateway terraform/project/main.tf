provider "aws" {
  region = "us-east-1"
}

module "dynamodb" {
  source     = "../modules/dynamodb"
  table_name = "employeeData"
  hash_key   = "empId"
}

module "iam_policy" {
  source              = "../modules/iam"
  policy_name         = "LambdaDynamoDBAccessPolicy"
  dynamodb_table_arn  = module.dynamodb.dynamodb_table_arn
}

module "lambda_get" {
  source         = "../modules/lambda"
  function_name  = "getEmployeeFunction"
  handler        = "index.handler"
  runtime        = "nodejs14.x"
  s3_key         = "s3://your-bucket/get_function.zip"
  policy_arn     = module.iam_policy.iam_policy_arn
}

module "lambda_post" {
  source         = "../modules/lambda"
  function_name  = "postEmployeeFunction"
  handler        = "index.handler"
  runtime        = "nodejs14.x"
  s3_key         = "s3://your-bucket/post_function.zip"
  policy_arn     = module.iam_policy.iam_policy_arn
}

module "api_gateway" {
  source         = "../modules/api_gateway"
  api_name       = "example_api"
  api_description = "Example API Gateway with CORS"
  stage_name     = "prod"
  lambda_get_arn = module.lambda_get.lambda_function_arn
  lambda_post_arn = module.lambda_post.lambda_function_arn
  path_part      = "employee"
}