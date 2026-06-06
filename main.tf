terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "iam" {
  source    = "./modules/iam"
  table_arn = module.dynamodb.arn
}

module "lambda" {
  source        = "./modules/lambda"
  source_dir    = "${path.module}/src/cards/create"
  function_name = "create-card"
  role_arn      = module.iam.role_arn
  table_name    = module.dynamodb.name
}

module "apigw" {
  source = "./modules/apigateway"

  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}

output "lambda_name" {
  value = module.lambda.function_name
}

output "table_name" {
  value = module.dynamodb.name
}

output "api_endpoint" {
  value = module.apigw.api_endpoint
}
