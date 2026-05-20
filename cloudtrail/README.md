# CloudTrail 確認方法

> **証跡（Trail）の設定は不要です。**  
> イベントの確認は CloudTrail の **イベント履歴（Event History）** で行います。  
> イベント履歴はデフォルトで有効で、管理イベントを90日間保持します。

GitHub Actions の OIDC 認証が成功すると、  
AWS CloudTrail に `AssumeRoleWithWebIdentity` イベントが記録されます。

---

## 確認する AWS CloudTrail イベント

### OIDC 方式で確認できるイベント

| イベント名 | 説明 |
|---|---|
| `AssumeRoleWithWebIdentity` | OIDC による IAM Role 引受 |
| `GetCallerIdentity` | 認証後の身元確認 |

### Secrets 方式で確認できるイベント

| イベント名 | 説明 |
|---|---|
| `GetCallerIdentity` | IAM ユーザーキーによる身元確認 |

> **比較ポイント**: OIDC 方式は `AssumeRoleWithWebIdentity` が記録され、  
> いつ・どのリポジトリが・どのロールを引き受けたかが追跡できる。  
> Secrets 方式は IAM ユーザーの長期キーで直接アクセスされる。

> **`GetCallerIdentity` が見つからない場合の確認事項**:  
> - リージョンの確認: STS グローバルエンドポイント使用時は `us-east-1` に記録される場合がある  
> - フィルタの確認: コンソールが Write イベントのみ表示になっていないか確認する  
> - 遅延: CloudTrail は数分の遅延がある

---

## AWS マネジメントコンソールで確認する方法

1. AWS マネジメントコンソールにログイン
2. CloudTrail を開く
3. Event history を選択
4. フィルタ条件を設定:

| フィルタ項目 | 値 |
|---|---|
| Event name | `AssumeRoleWithWebIdentity` |
| Time range | workflow を実行した時刻前後 |

---

## CloudTrail イベントの読み方

### AssumeRoleWithWebIdentity のイベント例（JSON 抜粋）

```json
{
  "eventName": "AssumeRoleWithWebIdentity",
  "eventSource": "sts.amazonaws.com",
  "userIdentity": {
    "type": "WebIdentityUser",
    "principalId": "token.actions.githubusercontent.com:repo:your-org/demo-github-supply-chain:ref:refs/heads/main",
    "userName": "repo:your-org/demo-github-supply-chain:ref:refs/heads/main",
    "identityProvider": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  },
  "requestParameters": {
    "roleArn": "arn:aws:iam::123456789012:role/demo-github-oidc-role",
    "roleSessionName": "GitHubActions-OIDC-Verify"
  }
}
```

### 確認ポイント

| フィールド | 確認内容 |
|---|---|
| `eventName` | `AssumeRoleWithWebIdentity` であること |
| `userIdentity.type` | `WebIdentityUser` であること |
| `userIdentity.userName` | `repo:your-org/your-repo:ref:refs/heads/main` の形式であること |
| `userIdentity.identityProvider` | `arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com` の形式であること |
| `requestParameters.roleArn` | 期待する IAM Role ARN であること |
| `requestParameters.roleSessionName` | workflow で指定したセッション名であること |

---

## Secrets 方式との比較

| 比較項目 | Secrets 方式 | OIDC 方式 |
|---|---|---|
| CloudTrail イベント | `GetCallerIdentity` のみ | `AssumeRoleWithWebIdentity` + `GetCallerIdentity` |
| 認証主体 | IAM ユーザー（長期キー） | IAM Role（OIDC 経由） |
| 追跡容易性 | リポジトリ情報なし | `userIdentity.userName` にリポジトリ・ブランチ名が記録 |
| 監査 | キーが誰に漏洩しても区別できない | リポジトリ・ブランチ単位で追跡可能 |

---

## 注意事項

- CloudTrail のイベント履歴は **デフォルトで90日間** 保持される
- 長期保存が必要な場合は CloudTrail Trail を S3 に設定すること
- 検証後は不要なイベントを残さないよう、使用したリソースを削除すること
