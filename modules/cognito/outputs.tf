output "cognito_hosted_ui_domain" {
  description = "Cognito Hosted UI base URL"
  value       = "https://${aws_cognito_user_pool_domain.flashcards.domain}.auth.${var.region}.amazoncognito.com"
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.flashcards.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.web.id
}