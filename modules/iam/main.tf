data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "ddb_access" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]

    resources = [var.flashcards_table_arn]
  }
}

resource "aws_iam_policy" "ddb_access" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.ddb_access.json
}

resource "aws_iam_role_policy_attachment" "ddb_attach" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.ddb_access.arn
}

data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

data "aws_iam_policy_document" "eventbridge_access" {
  statement {
    actions = [
      "events:PutEvents"
    ]
    resources = [data.aws_cloudwatch_event_bus.default.arn]
  }
}

resource "aws_iam_policy" "eventbridge_access" {
  name   = "eventbridge-put-events"
  policy = data.aws_iam_policy_document.eventbridge_access.json
}

resource "aws_iam_role_policy_attachment" "eventbridge_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.eventbridge_access.arn
}
