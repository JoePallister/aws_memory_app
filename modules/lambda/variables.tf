variable "function_name" {
  type    = string
  default = "release-control"
}

variable "source_dir" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "handler" {
  type    = string
  default = "handler.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "table_name" {
  type = string
}
