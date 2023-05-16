data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch_emf_role" {
  name               = "cloudwatch_emf_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "default_lambda_policy" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams"
    ]

    resources = ["arn:aws:dynamodb:*:*:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "default_lambda_policy"
  path        = "/"
  description = "IAM policy for logging and VPC from a lambda"
  policy      = data.aws_iam_policy_document.default_lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.cloudwatch_emf_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "aws_iam_policy_document" "assume_role_gtw" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "apigateway_integration_role" {
  name               = "apigateway_integration_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_gtw.json
}

data "aws_iam_policy_document" "apigateway_integration_policy" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["arn:aws:lambda:*:*:*"]
  }
}

resource "aws_iam_policy" "default_apigateway_integration_policy" {
  name        = "default_apigateway_integration_policy"
  path        = "/"
  description = "IAM policy for api gateway invoking lambda function"
  policy      = data.aws_iam_policy_document.apigateway_integration_policy.json
}

resource "aws_iam_role_policy_attachment" "apigateway_integration_role" {
  role       = aws_iam_role.apigateway_integration_role.name
  policy_arn = aws_iam_policy.default_apigateway_integration_policy.arn
}
