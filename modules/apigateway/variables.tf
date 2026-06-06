variable "lambda_invoke_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "api_name" {
  type    = string
  default = "release-control-api"
}
