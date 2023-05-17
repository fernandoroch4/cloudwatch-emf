resource "aws_athena_data_catalog" "data_source" {
  name        = "cloudwatch-metrics"
  description = "CloudWatch Metrics data source"
  type        = "LAMBDA"

  parameters = {
    "function" = "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:athenacloudwatchmetricsconnector"
  }
}

resource "aws_athena_workgroup" "workgroup" {
  name          = "cloudwatch-emf-workgroup"
  force_destroy = true

  configuration {
    result_configuration {
      output_location = "s3://${data.aws_caller_identity.current.account_id}-temp/athena/cloudwatch-emf-workgroup/output/"
    }
  }
}
