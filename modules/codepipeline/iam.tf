#
# CloudWatch Events
#
resource "aws_iam_role" "cloudwatch_events" {
  name = "${var.prefix}-${var.env}-event"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "events.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_events_codepipeline" {
  name = "${var.prefix}-${var.env}-event-pipeline"
  role = aws_iam_role.cloudwatch_events.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codepipeline:StartPipelineExecution"
        ],
        Resource : [
          aws_codepipeline.this.arn
        ],
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline
#
resource "aws_iam_role" "codepipeline" {
  name = "${var.prefix}-${var.env}-pipeline"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codepipeline.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.prefix}-${var.env}-pipeline"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Resource : aws_iam_role.codepipeline_codecommit.arn,
        Effect : "Allow"
      },
      {
        Action : "sts:AssumeRole",
        Resource : aws_iam_role.codepipeline_codebuild.arn,
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline -> CodeCommit
#
resource "aws_iam_role" "codepipeline_codecommit" {
  name = "${var.prefix}-${var.env}-pipeline-commit"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "repository" {
  name = "${var.prefix}-${var.env}-repository"
  role = aws_iam_role.codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ],
        Resource : aws_codecommit_repository.this.arn,
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "artifacts_store" {
  name = "${var.prefix}-${var.env}-artifacts-store"
  role = aws_iam_role.codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:Get*",
          "s3:Put*",
        ],
        Resource : "${aws_s3_bucket.artifacts_store.arn}/*",
        Effect : "Allow"
      },
      {
        Action : [
          "s3:ListBucket",
        ],
        Resource : aws_s3_bucket.artifacts_store.arn,
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline -> CodeBuild
#
resource "aws_iam_role" "codepipeline_codebuild" {
  name = "${var.prefix}-${var.env}-pipeline-build"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "build" {
  name = "${var.prefix}-${var.env}-build"
  role = aws_iam_role.codepipeline_codebuild.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ],
        Resource : [
          aws_codebuild_project.dockle_check.arn,
          aws_codebuild_project.secrets_check.arn,
        ],
        Effect : "Allow"
      },
      {
        Action : [
          "logs:CreateLogGroup"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

#
# CodeBuild
#
resource "aws_iam_role" "dockle_check" {
  name = "${var.prefix}-${var.env}-dockle-check"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codebuild.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "dockle_check" {
  name = "${var.prefix}-${var.env}-dockle-check"
  role = aws_iam_role.dockle_check.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "*",
        Effect : "Allow"
      },
      {
        Action : [
          "logs:CreateLogGroup"
        ],
        Resource : "*",
        Effect : "Allow"
      },
      {
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "secrets_check" {
  name = "${var.prefix}-${var.env}-secrets-check"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codebuild.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "secrets_check" {
  name = "${var.prefix}-${var.env}-secrets-check"
  role = aws_iam_role.secrets_check.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "*",
        Effect : "Allow"
      },
      {
        Action : [
          "logs:CreateLogGroup"
        ],
        Resource : "*",
        Effect : "Allow"
      },
      {
        Action : [
          "codecommit:GitPull"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}
