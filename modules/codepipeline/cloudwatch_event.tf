resource "aws_cloudwatch_event_rule" "this" {
  name = "${var.prefix}-${var.env}-repo-state-change"
  event_pattern = jsonencode({
    detail-type : [
      "CodeCommit Repository State Change"
    ],
    resources : [
      aws_codecommit_repository.this.arn
    ],
    source : [
      "aws.codecommit"
    ],
    detail : {
      event : [
        "referenceCreated",
        "referenceUpdated"
      ],
      referenceName : [
        "${var.branch_name}"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "this" {
  rule     = aws_cloudwatch_event_rule.this.id
  arn      = aws_codepipeline.this.arn
  role_arn = aws_iam_role.cloudwatch_events.arn
}
