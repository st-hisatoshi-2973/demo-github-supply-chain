# ==============================================================
# IAM User - Secrets 方式 検証用
# ==============================================================
#
# 目的: GitHub Secrets に登録する AWS アクセスキーを
#       Terraform で一元管理し、検証後に確実に削除する。
#
# 注意:
#   - tfstate にアクセスキーの秘密鍵が平文で保存される
#   - 検証専用アカウントのみで使用すること
#   - 検証後は必ず terraform destroy で削除すること
#
# ==============================================================

resource "aws_iam_user" "secrets_verify" {
  name = var.secrets_iam_user_name

  tags = {
    Purpose = "Secrets verification for demo-github-supply-chain"
  }
}

# 最小権限ポリシー（GetCallerIdentity のみ）
data "aws_iam_policy_document" "secrets_verify_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "secrets_verify" {
  name   = "${var.secrets_iam_user_name}-policy"
  user   = aws_iam_user.secrets_verify.name
  policy = data.aws_iam_policy_document.secrets_verify_permissions.json
}

# アクセスキーの発行
resource "aws_iam_access_key" "secrets_verify" {
  user = aws_iam_user.secrets_verify.name
}
