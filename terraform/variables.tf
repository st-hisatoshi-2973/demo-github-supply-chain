variable "aws_region" {
  description = "AWS リージョン（検証用）"
  type        = string
  default     = "ap-northeast-1"
}

variable "github_org" {
  description = "GitHub Organization 名または個人アカウント名"
  type        = string
  # 例: "your-org-name" または "your-github-username"
}

variable "github_repo" {
  description = "GitHub リポジトリ名（このリポジトリ）"
  type        = string
  default     = "demo-github-supply-chain"
}

variable "github_branch" {
  description = "OIDC を許可するブランチ（最小権限のためブランチを絞る）"
  type        = string
  default     = "main"
}

variable "oidc_role_name" {
  description = "作成する IAM Role 名"
  type        = string
  default     = "demo-github-oidc-role"
}

variable "secrets_iam_user_name" {
  description = "Secrets 方式検証用 IAM ユーザー名"
  type        = string
  default     = "demo-secrets-verify-user"
}
