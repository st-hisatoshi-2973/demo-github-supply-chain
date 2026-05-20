# クリーンアップ手順

検証完了後は、以下の手順でリソースを削除してください。  
**検証後の放置は不要な課金・セキュリティリスクにつながります。**

---

## クリーンアップ手順の全体像

```
Step 1: GitHub Secrets の削除
Step 2: GitHub Variables の削除
Step 3: Terraform で AWS リソース削除
Step 4: 削除確認
```

---

## Step 1: GitHub Secrets の削除

1. GitHub リポジトリ > Settings > Secrets and variables > Actions
2. 以下の Secrets を削除する:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

---

## Step 2: GitHub Variables の削除

1. GitHub リポジトリ > Settings > Secrets and variables > Actions > Variables
2. 以下の Variables を削除する:
   - `OIDC_ROLE_ARN`

---

## Step 3: Terraform で AWS リソースを削除

```bash
cd terraform/

# 削除されるリソースを事前確認
terraform plan -destroy

# 削除実行
terraform destroy

# 確認プロンプトに "yes" と入力する
```

削除されるリソース:
- `aws_iam_openid_connect_provider.github_actions` — GitHub OIDC Provider
- `aws_iam_role.github_oidc` — OIDC 用 IAM Role
- `aws_iam_role_policy.github_oidc` — IAM Role のインラインポリシー
- `aws_iam_user.secrets_verify` — Secrets 方式検証用 IAM ユーザー
- `aws_iam_user_policy.secrets_verify` — IAM ユーザーのインラインポリシー
- `aws_iam_access_key.secrets_verify` — IAM ユーザーのアクセスキー

---

## Step 4: 削除確認

### Terraform リソースの確認

```bash
cd terraform/
terraform show
# 出力が空であれば削除完了
```

### AWS コンソールでの確認

以下を手動確認する:

| 確認項目 | 確認場所 |
|---|---|
| IAM Role が削除されたか | IAM > Roles > `demo-github-oidc-role` を検索 |
| OIDC Provider が削除されたか | IAM > Identity providers > `token.actions.githubusercontent.com` |
| IAM ユーザーが削除されたか | IAM > Users > 検証用ユーザー名を検索 |

---

## 削除後のチェックリスト

- [ ] GitHub Secrets から AWS_ACCESS_KEY_ID を削除した
- [ ] GitHub Secrets から AWS_SECRET_ACCESS_KEY を削除した
- [ ] GitHub Variables から OIDC_ROLE_ARN を削除した
- [ ] `terraform destroy` が成功した
- [ ] AWS コンソールで IAM Role が存在しないことを確認した
- [ ] AWS コンソールで OIDC Provider が削除されたことを確認した（または共用なら残す）
