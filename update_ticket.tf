data "archive_file" "update_ticket" {
  type        = "zip"
  source_file = "code/update_ticket/main.py"
  output_path = "code/update_ticket/update_ticket.zip"
}

resource "aws_lambda_function" "update_ticket" {
  filename         = "code/update_ticket/update_ticket.zip"
  function_name    = "update_ticket"
  description      = "Update a ticket"
  role             = aws_iam_role.cloudwatch_emf_role.arn
  source_code_hash = data.archive_file.update_ticket.output_base64sha256
  handler          = "main.handler"
  runtime          = "python3.10"
  architectures    = ["arm64"]
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      "LOG_LEVEL"         = "20"
      "TICKET_TABLE_NAME" = aws_dynamodb_table.ticket.id
    }
  }
  tags = {
    workload = "cloudwatch_emf"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
}
