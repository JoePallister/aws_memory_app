variable "create_card_lambda_invoke_arn" {
  type = string
}

variable "create_card_function_name" {
  type = string
}

variable "api_name" {
  type    = string
  default = "cards-api"
}

variable "interval_increment_lambda_invoke_arn" {
  type = string
}

variable "interval_increment_function_name" {
  type = string
}
