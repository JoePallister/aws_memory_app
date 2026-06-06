variable "role_name" {
  type    = string
  default = "release-control-lambda-role"
}

variable "policy_name" {
  type    = string
  default = "release-control-ddb-access"
}

variable "flashcards_table_arn" {
  type = string
}
