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

module "flashcards" {
  source         = "./modules/dynamodb"
  name           = "flashcards"
  hash_key       = "user_id"
  hash_key_type  = "S"
}

module "iam" {
  source    = "./modules/iam"
  flashcards_table_arn = module.flashcards.arn
}

module "create-card" {
  source        = "./modules/lambda"
  source_dir    = "${path.module}/src/cards/create"
  function_name = "create-card"
  role_arn      = module.iam.role_arn
  table_name    = module.flashcards.name
}

module "apigw" {
  source = "./modules/apigateway"
  lambda_invoke_arn    = module.create-card.invoke_arn
  lambda_function_name = module.create-card.function_name
}

output "lambda_name" {
  value = module.create-card.function_name
}

output "flashcards_table_name" {
  value = module.flashcards.name
}

output "api_endpoint" {
  value = module.apigw.api_endpoint
}
