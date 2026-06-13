resource "aws_cognito_user_pool" "flashcards" {
  name = "flashcards-users"

  username_attributes = ["email"]

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}

resource "aws_cognito_user_pool_client" "web" {
  name         = "flashcards-web"
  user_pool_id = aws_cognito_user_pool.flashcards.id

  generate_secret = false

  callback_urls = [
    "http://localhost:8000/callback.html"
  ]

  logout_urls = [
    "http://localhost:8000/index.html"
  ]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "flashcards" {
  domain       = "flashcards-app-abcdefgh"
  user_pool_id = aws_cognito_user_pool.flashcards.id
}