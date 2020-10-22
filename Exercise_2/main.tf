terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_iam_role" "udacity_cand_c2_role" {
  name = "udacity_cand_c2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "udacity_cand_c2_lambda" {
  filename      = "greet_lambda.zip"
  function_name = "udacity_cand_c2_greet_lambda"
  role          = aws_iam_role.udacity_cand_c2_role.arn
  handler       = "greet_lambda.lambda_handler"

  source_code_hash = filebase64sha256("greet_lambda.zip")

  runtime = "python3.8"

  environment {
    variables = {
      greeting = "Hello from Udacity!"
    }
  }
}


resource "aws_cloudwatch_log_group" "udacity_cand_c2_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.udacity_cand_c2_lambda.function_name}"
  retention_in_days = 1
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.udacity_cand_c2_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}