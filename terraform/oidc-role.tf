# ==============================================================
# GitHub Actions OIDC Provider
# ==============================================================
#
# GitHub の OIDC Provider を AWS に登録する。
#
# ==============================================================

# GitHub OIDC Provider の thumbprint
#
# 【重要】2023年以降の AWS の挙動について:
#   AWS は token.actions.githubusercontent.com に対して thumbprint による検証を行わず、
#   ルート CA を直接信頼する方式に変更済み。
#   そのため thumbprint_list の値は実質的に検証に使われない。
#   ただし Terraform の aws_iam_openid_connect_provider リソースでは
#   thumbprint_list は必須フィールドのため、値を設定しておく。
#
# 参考:
#   https://github.blog/changelog/2023-06-27-github-actions-oidc-integration-with-aws-no-longer-requires-pinning-of-intermediate-tls-certificates/
#   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html
locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"

  # thumbprint_list は Terraform リソースの必須フィールドのため値が必要だが、
  # AWS は token.actions.githubusercontent.com に対して検証に使用しない。
  github_oidc_thumbprint = "ffffffffffffffffffffffffffffffffffffffff"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = local.github_oidc_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    local.github_oidc_thumbprint,
  ]
}

# ==============================================================
# IAM Role - Trust Policy（GitHub Actions からの引受を許可）
# ==============================================================

data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # リポジトリ・ブランチを限定する（最小権限の重要ポイント）
    # sub の形式: repo:<org>/<repo>:ref:refs/heads/<branch>
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}",
      ]
    }
  }
}

resource "aws_iam_role" "github_oidc" {
  name               = var.oidc_role_name
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json

  max_session_duration = 3600 # 最大1時間

  description = "GitHub Actions OIDC role for demo-github-supply-chain (verification)"
}

# ==============================================================
# IAM Policy - 最小権限
# ==============================================================
#
# 検証目的のため GetCallerIdentity のみ許可する。
# 実際のユースケースでは必要な権限のみ追加すること。
#
# ==============================================================

data "aws_iam_policy_document" "github_oidc_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
    # GetCallerIdentity はリソース指定不可のため * を使用
  }

  # S3 読み取り（デモ用バケットのみ）
  # 最小権限: ListBucket と GetObject のみ許可する
  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.demo_s3_bucket_name}",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${var.demo_s3_bucket_name}/*",
    ]
  }
}

resource "aws_iam_role_policy" "github_oidc" {
  name   = "${var.oidc_role_name}-policy"
  role   = aws_iam_role.github_oidc.id
  policy = data.aws_iam_policy_document.github_oidc_permissions.json
}
