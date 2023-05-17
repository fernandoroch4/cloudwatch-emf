resource "aws_quicksight_account_subscription" "subscription" {
  aws_account_id        = data.aws_caller_identity.current.account_id
  account_name          = "rocha-lab-quicksight"
  first_name            = "Fernando"
  last_name             = "Rocha"
  authentication_method = "IAM_AND_QUICKSIGHT"
  edition               = "STANDARD"
  notification_email    = "fernandoroch4@gmail.com"
}

resource "aws_quicksight_data_source" "default" {
  data_source_id = "athena-cloudwatch-metrics"
  name           = "Athena CloudWatch Metrics"

  parameters {
    athena {
      work_group = aws_athena_workgroup.workgroup.id
    }
  }

  type = "ATHENA"
}
