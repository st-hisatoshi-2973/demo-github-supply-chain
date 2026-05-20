# ==============================================================
# 注意: 専用の検証用 AWS アカウントでのみ実行してください。
#       本番アカウントは絶対に使用しないでください。
#
# profile = "terraform-demo" は環境に合わせて変更してください。
# ~/.aws/config に該当プロファイルを設定する必要があります。
#
# [profile terraform-demo]
# region = ap-northeast-1
# ==============================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform-demo"

  default_tags {
    tags = {
      Project     = "demo-github-supply-chain"
      Environment = "verification"
      ManagedBy   = "terraform"
    }
  }
}
