# 計画・タスク管理

**実行済み計画**: [docs/PLAN-EXECUTED.md](docs/PLAN-EXECUTED.md) を参照

---

## 完了: Dockerでのマイグレーションテスト (2025-12-06)

### テスト結果サマリー

| テスト | 期待結果 | 実際の結果 |
|--------|---------|-----------|
| マイグレーション実行 | version 4 | ✅ version 4 |
| テーブル数 | 27テーブル | ✅ 28テーブル（schema_migrations含む） |
| RLS（セッション変数なし） | 0件返却 | ✅ 0件 |
| RLS（ACME設定後） | ACME のデータのみ | ✅ acme_report.pdf のみ |
| RLS（Globex設定後） | Globex のデータのみ | ✅ globex_data.csv のみ |
| superadmin | 全データアクセス可 | ✅ 2件全て表示 |
| ロールバック | エラーなく戻せる | ✅ version 3 に戻り、再適用で version 4 |

### 修正事項

- `internal/database/connection.go`: ローカル開発用にパスワードフィールドを追加
- `cmd/migrate/main.go`: `--password` フラグとviperバインディングを追加

---

## 次のステップ（予定）

- CloudSQL本番環境へのマイグレーションテスト
- アプリケーションコードでのRLS統合実装
- CI/CDパイプラインへのマイグレーション組み込み
