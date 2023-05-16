data "archive_file" "delete_ticket" {
  type        = "zip"
  source_file = "../code/delete_ticket/main.py"
  output_path = "../code/delete_ticket/delete_ticket.zip"
}

resource "aws_lambda_function" "delete_ticket" {
  filename         = "../code/delete_ticket/delete_ticket.zip"
  function_name    = "delete_ticket"
  description      = "Delete a ticket"
  role             = aws_iam_role.cloudwatch_emf_role.arn
  source_code_hash = data.archive_file.delete_ticket.output_base64sha256
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
