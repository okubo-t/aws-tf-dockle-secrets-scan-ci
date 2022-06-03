resource "aws_codepipeline" "this" {
  name     = "${var.prefix}-${var.env}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts_store.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      provider = "CodeCommit"
      category = "Source"
      configuration = {
        BranchName           = var.branch_name
        PollForSourceChanges = "false"
        RepositoryName       = aws_codecommit_repository.this.id
      }
      name             = aws_codecommit_repository.this.id
      owner            = "AWS"
      version          = "1"
      output_artifacts = ["source_output"]
      role_arn         = aws_iam_role.codepipeline_codecommit.arn
    }
  }

  stage {
    name = "Secrets_Check"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.secrets_check.name
      }
      input_artifacts = ["source_output"]
      name            = aws_codebuild_project.secrets_check.name
      provider        = "CodeBuild"
      owner           = "AWS"
      version         = "1"
      role_arn        = aws_iam_role.codepipeline_codebuild.arn
    }
  }

  stage {
    name = "Dockle_Check"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.dockle_check.name
      }
      input_artifacts  = ["source_output"]
      name             = aws_codebuild_project.dockle_check.name
      provider         = "CodeBuild"
      owner            = "AWS"
      version          = "1"
      role_arn         = aws_iam_role.codepipeline_codebuild.arn
      output_artifacts = ["dockle_check_output"]
    }
  }
}
