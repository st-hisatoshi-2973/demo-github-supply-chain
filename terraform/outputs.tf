output "oidc_role_arn" {
  description = "GitHub Actions OIDC 用 IAM Role ARN（workflow の role-to-assume に設定する）"
  value       = aws_iam_role.github_oidc.arn
}

output "oidc_role_name" {
  description = "GitHub Actions OIDC 用 IAM Role 名"
  value       = aws_iam_role.github_oidc.name
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "secrets_verify_access_key_id" {
  description = "Secrets 方式検証用 IAM ユーザーのアクセスキー ID（GitHub Secrets の AWS_ACCESS_KEY_ID に設定する）"
  value       = aws_iam_access_key.secrets_verify.id
}

output "secrets_verify_secret_access_key" {
  description = "Secrets 方式検証用 IAM ユーザーのシークレットキー（GitHub Secrets の AWS_SECRET_ACCESS_KEY に設定する）"
  value       = aws_iam_access_key.secrets_verify.secret
  sensitive   = true
  # terraform output -raw secrets_verify_secret_access_key で取得する
}

output "demo_s3_bucket_name" {
  description = "デモ用 S3 バケット名（GitHub Variables の DEMO_S3_BUCKET に設定する）"
  value       = aws_s3_bucket.demo_oidc.bucket
}

output "next_steps" {
  description = "次のステップ"
  value       = <<-EOT
    次のステップ:
    1. oidc_role_arn の値を GitHub Variables > OIDC_ROLE_ARN に設定する
    2. demo_s3_bucket_name の値を GitHub Variables > DEMO_S3_BUCKET に設定する
    3. GitHub Actions > [DEMO] OIDC 方式 を手動実行する
    4. CloudTrail イベント履歴で AssumeRoleWithWebIdentity を確認する
  EOT
}
