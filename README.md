# CloudSQL Migration Tool

Go製のCloudSQL（PostgreSQL/MySQL）マイグレーション管理ツール

## 機能

- PostgreSQL / MySQL 両対応
- Google CloudSQL Auth Proxy 統合
- ローカル開発用 Docker Compose 環境
- CLI によるマイグレーション管理

## プロジェクト構成

```
cloudsql/
├── cmd/migrate/          # CLIツール
├── internal/database/    # DB接続・マイグレーション処理
├── migrations/
│   ├── postgres/         # PostgreSQL マイグレーション
│   └── mysql/            # MySQL マイグレーション
├── configs/              # 設定ファイル
├── scripts/              # デプロイスクリプト
├── docker-compose.yaml   # ローカル開発用
└── Makefile
```

## セットアップ

### 依存関係のインストール

```bash
make deps
```

### ローカル開発環境の起動

```bash
# PostgreSQL + MySQL + Adminer を起動
make docker-up

# Adminer UI: http://localhost:8080
```

## 使い方

### マイグレーションの作成

```bash
# PostgreSQL
make pg-create
# -> Migration name: を入力

# MySQL
make mysql-create
```

### マイグレーションの実行

```bash
# PostgreSQL
make pg-up      # 全マイグレーション実行
make pg-down    # 最後の1つをロールバック
make pg-version # 現在のバージョン確認

# MySQL
make mysql-up
make mysql-down
make mysql-version
```

### CloudSQL への接続

```bash
# 環境変数を設定
export GCP_PROJECT=your-project
export GCP_REGION=asia-northeast1
export PG_INSTANCE=your-postgres-instance
export DB_USER=postgres
export DB_PASSWORD=your-password
export DB_NAME=your-database

# マイグレーション実行
make cloudsql-pg-up
```

## CLI オプション

```bash
./bin/migrate --help

# オプション
--db         # データベースタイプ (postgres/mysql)
--config     # 設定ファイルパス
--host       # データベースホスト
--port       # データベースポート
--user       # ユーザー名
--password   # パスワード
--database   # データベース名
--cloudsql   # CloudSQL接続を使用
--project    # GCPプロジェクトID
--region     # CloudSQLリージョン
--instance   # CloudSQLインスタンス名
--private-ip # プライベートIPを使用
```

## 環境変数

設定は環境変数でも指定可能（`DB_` プレフィックス）:

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=postgres
export DB_DATABASE=myapp
```

## マイグレーションファイルの命名規則

```
{version}_{name}.up.sql    # マイグレーション
{version}_{name}.down.sql  # ロールバック
```

例:
```
000001_init.up.sql
000001_init.down.sql
000002_add_posts_table.up.sql
000002_add_posts_table.down.sql
```

## CloudSQL 接続要件

1. `gcloud` CLI がインストール済み
2. `gcloud auth application-default login` で認証済み
3. CloudSQL Admin API が有効化済み
4. 適切な IAM 権限（Cloud SQL Client）

## ライセンス

MIT
