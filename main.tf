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
  range_key      = "card_id"
  range_key_type = "S"
}

module "iam" {
  source               = "./modules/iam"
  flashcards_table_arn = module.flashcards.arn
}

module "create_card" {
  source        = "./modules/lambda"
  source_dir    = "${path.module}/src/cards/create"
  function_name = "create_card"
  role_arn      = module.iam.role_arn
  table_name    = module.flashcards.name
}

module "review_scheduler" {
  source        = "./modules/lambda"
  source_dir    = "${path.module}/src/cards/review_scheduler"
  function_name = "review_scheduler"
  role_arn      = module.iam.role_arn
  table_name    = module.flashcards.name
}

module "interval_increment" {
  source        = "./modules/lambda"
  source_dir    = "${path.module}/src/cards/interval_increment"
  function_name = "interval_increment"
  role_arn      = module.iam.role_arn
  table_name    = module.flashcards.name
}

module "apigw" {
  source                               = "./modules/apigateway"
  create_card_lambda_invoke_arn        = module.create_card.invoke_arn
  create_card_function_name            = module.create_card.function_name
  interval_increment_lambda_invoke_arn = module.interval_increment.invoke_arn
  interval_increment_function_name     = module.interval_increment.function_name
  cognito_issuer   = module.cognito.issuer_url
  cognito_audience  = module.cognito.user_pool_client_id
}

module "cognito" {
  source = "./modules/cognito"
  region = var.region
}

output "lambda_name" {
  value = module.create_card.function_name
}

output "flashcards_table_name" {
  value = module.flashcards.name
}

output "api_endpoint" {
  value = module.apigw.api_endpoint
}

output "cognito_hosted_ui_domain" {
  value = module.cognito.cognito_hosted_ui_domain
}

output "cognito_user_pool_id" {
  value = module.cognito.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}

resource "aws_cloudwatch_event_rule" "flashcard_created" {
  name = "flashcard-created"

  event_pattern = jsonencode({
    source        = ["anki.cards"]
    "detail-type" = ["FlashcardCreated"]
  })
}

resource "aws_cloudwatch_event_rule" "flashcard_reviewed" {
  name = "flashcard-reviewed"

  event_pattern = jsonencode({
    source        = ["anki.cards"]
    "detail-type" = ["FlashcardReviewed"]
  })
}

resource "aws_cloudwatch_event_target" "review_scheduler_lambda" {
  rule = aws_cloudwatch_event_rule.flashcard_created.name
  arn  = module.review_scheduler.arn
}

resource "aws_cloudwatch_event_target" "review_scheduler_lambda_update" {
  rule = aws_cloudwatch_event_rule.flashcard_reviewed.name
  arn  = module.review_scheduler.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.review_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.flashcard_created.arn
}

resource "aws_lambda_permission" "allow_eventbridge_reviewed" {
  statement_id  = "AllowExecutionFromEventBridgeReviewed"
  action        = "lambda:InvokeFunction"
  function_name = module.review_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.flashcard_reviewed.arn
}
