resource "aws_dynamodb_table" "ticket" {
  name             = "Ticket"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  hash_key         = "ticket_id"

  attribute {
    name = "ticket_id"
    type = "S"
  }

  ttl {
    attribute_name = "_time_to_expires"
    enabled        = true
  }

  tags = {
    Name     = "Ticket"
    workload = "cloudwatch_emf"
  }
}
