# 計画・タスク管理

**実行済み計画**: [docs/PLAN-EXECUTED.md](docs/PLAN-EXECUTED.md) を参照

---

## 未実行: Dockerでのマイグレーションテスト

### 1. Docker環境起動

```bash
# PostgreSQL + Adminer を起動
make docker-up

# 起動確認
docker ps

# ログ確認（エラーがないか）
docker-compose logs postgres
```

### 2. マイグレーション実行

```bash
# ビルド
make build

# マイグレーション実行
make pg-up

# バージョン確認
make pg-version
# -> 4 が表示されれば成功
```

### 3. テーブル確認（Adminer）

ブラウザで http://localhost:8080 にアクセス

| 項目 | 値 |
|------|-----|
| システム | PostgreSQL |
| サーバ | postgres |
| ユーザ名 | postgres |
| パスワード | postgres |
| データベース | myapp_postgres |

確認すべきテーブル:
- `organizations`
- `app_users`
- `user_organizations`
- `files`, `kudguri`, `dtakologs` など（全て organization_id 付き）

### 4. RLS動作テスト

```bash
# PostgreSQLに直接接続
docker exec -it cloudsql-postgres psql -U postgres -d myapp_postgres
```

```sql
-- テスト用企業を作成
INSERT INTO organizations (id, name, slug)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'ACME Corp', 'acme'),
  ('22222222-2222-2222-2222-222222222222', 'Globex Inc', 'globex');

-- テストユーザーを作成
INSERT INTO app_users (id, iam_email, display_name, is_superadmin)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user@example.com', 'Test User', false);

-- ユーザーをACMEに所属させる
INSERT INTO user_organizations (user_id, organization_id, role, is_default)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'admin', true);

-- テストデータ挿入
INSERT INTO files (uuid, organization_id, filename, created, type)
VALUES
  ('file-001', '11111111-1111-1111-1111-111111111111', 'acme_report.pdf', NOW()::TEXT, 'pdf'),
  ('file-002', '22222222-2222-2222-2222-222222222222', 'globex_data.csv', NOW()::TEXT, 'csv');

-- RLSテスト: セッション変数なしでクエリ
SELECT * FROM files;
-- -> 0件（RLSでブロック）

-- ACME社として設定
SET app.current_organization_id = '11111111-1111-1111-1111-111111111111';

-- 再度クエリ
SELECT * FROM files;
-- -> acme_report.pdf のみ表示（1件）

-- Globex社として設定
SET app.current_organization_id = '22222222-2222-2222-2222-222222222222';

SELECT * FROM files;
-- -> globex_data.csv のみ表示（1件）

-- superadminテスト
UPDATE app_users SET is_superadmin = true WHERE iam_email = 'user@example.com';
SET app.current_user_email = 'user@example.com';

SELECT * FROM files;
-- -> 両方表示（2件）
```

### 5. ロールバックテスト

```bash
# 1つ戻す
make pg-down

# バージョン確認
make pg-version
# -> 3

# 全て戻す（注意: データ消失）
./bin/migrate --db=postgres --config=./configs/config.postgres.yaml down-all

# 再度適用
make pg-up
```

### 6. クリーンアップ

```bash
# Dockerボリューム含めて完全削除
docker-compose down -v

# 再起動（クリーンな状態）
make docker-up
make pg-up
```

### 期待される結果

| テスト | 期待結果 |
|--------|---------|
| マイグレーション実行 | version 4 |
| テーブル数 | 27テーブル（organizations, app_users, user_organizations + 24ビジネステーブル） |
| RLS（セッション変数なし） | 0件返却 |
| RLS（org設定後） | 該当orgのデータのみ |
| superadmin | 全データアクセス可 |
| ロールバック | エラーなく戻せる |
