# ==============================================================
# S3 バケット - OIDC デモ用
# ==============================================================
#
# 目的: OIDC で取得した短期認証情報が IAM Policy の範囲で
#       実際に S3 へアクセスできることを確認するためのバケット。
#
# 注意:
#   - ダミーデータのみ格納する。実データを置かないこと。
#   - パブリックアクセスは全てブロック済み。
#   - 検証後は必ず terraform destroy で削除すること。
#
# ==============================================================

resource "aws_s3_bucket" "demo_oidc" {
  bucket = var.demo_s3_bucket_name
}

# パブリックアクセスを全てブロック
resource "aws_s3_bucket_public_access_block" "demo_oidc" {
  bucket = aws_s3_bucket.demo_oidc.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ダミーファイル
resource "aws_s3_object" "dummy_secret" {
  bucket = aws_s3_bucket.demo_oidc.id
  key    = "dummy-secret.txt"

  content = <<-EOT
    This is dummy data for security training.
    No real customer data is included.

    [DEMO] This file demonstrates that OIDC short-lived tokens
    can access S3 within the permissions granted by IAM Policy.

    Key learning:
    - OIDC removes the need to store long-term credentials
    - But IAM Policy still controls what the token can access
    - Minimum privilege principle applies to OIDC roles too
  EOT

  content_type = "text/plain"
}
