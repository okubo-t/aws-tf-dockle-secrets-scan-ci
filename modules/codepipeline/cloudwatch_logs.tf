resource "aws_cloudwatch_log_group" "dockle_check" {
  name              = "/aws/codebuild/${var.prefix}-${var.env}-dockle-check"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "secrets_check" {
  name              = "/aws/codebuild/${var.prefix}-${var.env}-secrets-check"
  retention_in_days = 30
}
