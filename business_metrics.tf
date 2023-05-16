data "archive_file" "business_metrics" {
  type        = "zip"
  source_dir  = "code/business_metrics/"
  output_path = "code/business_metrics/business_metrics.zip"
}

resource "aws_lambda_function" "business_metrics" {
  filename         = "code/business_metrics/business_metrics.zip"
  function_name    = "business_metrics"
  description      = "Generate cloudwatch metrics using emf"
  role             = aws_iam_role.cloudwatch_emf_role.arn
  source_code_hash = data.archive_file.business_metrics.output_base64sha256
  handler          = "main.handler"
  runtime          = "python3.10"
  architectures    = ["arm64"]
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      "LOG_LEVEL" = "20"
    }
  }
  tags = {
    workload = "cloudwatch_emf"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
}

resource "aws_lambda_event_source_mapping" "stream" {
  event_source_arn  = aws_dynamodb_table.ticket.stream_arn
  function_name     = aws_lambda_function.business_metrics.arn
  starting_position = "LATEST"
}
