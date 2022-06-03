resource "aws_codebuild_project" "dockle_check" {
  name          = "${var.prefix}-${var.env}-dockle-check"
  build_timeout = "60"
  service_role  = aws_iam_role.dockle_check.arn

  artifacts {
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.self.account_id
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.env
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.this.name
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
    buildspec       = file("./modules/codepipeline/buildspec_dockle_check.yml")
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = aws_cloudwatch_log_group.dockle_check.name
    }

    s3_logs {
      status = "DISABLED"
    }
  }

}

resource "aws_codebuild_project" "secrets_check" {
  name          = "${var.prefix}-${var.env}-secrets-check"
  build_timeout = "60"
  service_role  = aws_iam_role.secrets_check.arn

  artifacts {
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.self.account_id
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.env
    }

    environment_variable {
      name  = "CODE_REPO_NAME"
      value = aws_codecommit_repository.this.id
    }

    environment_variable {
      name  = "CODE_REPO_URL"
      value = aws_codecommit_repository.this.clone_url_http
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
    buildspec       = file("./modules/codepipeline/buildspec_secrets_check.yml")
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = aws_cloudwatch_log_group.secrets_check.name
    }

    s3_logs {
      status = "DISABLED"
    }
  }

}
