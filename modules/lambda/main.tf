data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/${var.function_name}.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role    = var.role_arn
  handler = var.handler

  runtime = var.runtime

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }
}
