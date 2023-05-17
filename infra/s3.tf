resource "aws_s3_bucket" "temp" {
  bucket        = "${data.aws_caller_identity.current.account_id}-temp"
  force_destroy = true

  tags = {
    Name     = "${data.aws_caller_identity.current.account_id}-temp"
    workload = "cloudwatch_emf"
  }
}
