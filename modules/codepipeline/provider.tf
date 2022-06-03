provider "aws" {
  profile = var.Account["profile"]
  region  = var.Account["region"]
}

data "aws_caller_identity" "self" {}
