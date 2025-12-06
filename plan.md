# CloudSQL マイグレーションツール - プロジェクト計画

## プロジェクト概要

Go製のCloudSQL（PostgreSQL/MySQL）マイグレーション管理ツール

## 完了したタスク

- [x] プロジェクト基本構造の作成
- [x] go.mod と依存関係の設定
- [x] DB接続管理コードの作成（CloudSQL Auth Proxy対応）
- [x] マイグレーションCLIツールの作成
- [x] サンプルマイグレーションファイルの作成（PostgreSQL/MySQL）
- [x] 設定ファイルとMakefileの作成
- [x] Docker Compose（ローカル開発用）の作成
- [x] READMEの作成
- [x] git init と初期コミット
- [x] go mod tidy で依存関係を解決
- [x] ビルドテスト成功

## プロジェクト構成

```
cloudsql/
├── cmd/migrate/main.go        # CLIツール
├── internal/database/
│   ├── connection.go          # DB接続（CloudSQL対応）
│   └── migrate.go             # マイグレーション処理
├── migrations/
│   ├── postgres/              # PostgreSQL用
│   └── mysql/                 # MySQL用
├── configs/
│   ├── config.yaml            # 共通設定
│   ├── config.postgres.yaml   # PostgreSQL設定
│   └── config.mysql.yaml      # MySQL設定
├── scripts/deploy.sh          # デプロイスクリプト
├── docker-compose.yaml        # ローカル開発用
├── Makefile
├── go.mod / go.sum
├── .gitignore
└── README.md
```

## 使用技術

| 項目 | 技術 |
|------|------|
| 言語 | Go 1.21+ |
| マイグレーション | golang-migrate/migrate v4 |
| CLI | spf13/cobra |
| 設定管理 | spf13/viper |
| PostgreSQL | lib/pq, pgxv5 |
| MySQL | go-sql-driver/mysql |
| CloudSQL | cloud.google.com/go/cloudsqlconn |

## CLIコマンド一覧

```bash
migrate up          # 全マイグレーション実行
migrate down        # 最後の1つをロールバック
migrate down-all    # 全ロールバック
migrate version     # 現在のバージョン確認
migrate create      # 新しいマイグレーション作成
migrate force       # バージョン強制設定
```

## Makeコマンド一覧

```bash
# ビルド
make build          # バイナリビルド
make deps           # 依存関係インストール
make clean          # クリーンアップ

# ローカル開発
make docker-up      # PostgreSQL + MySQL起動
make docker-down    # コンテナ停止

# PostgreSQL
make pg-up          # マイグレーション実行
make pg-down        # ロールバック
make pg-version     # バージョン確認
make pg-create      # 新規作成

# MySQL
make mysql-up
make mysql-down
make mysql-version
make mysql-create

# CloudSQL（本番）
make cloudsql-pg-up
make cloudsql-mysql-up
```

## 次のステップ（完了）

- [x] Docker Compose でローカルDB起動テスト
- [x] ローカルDBに対するマイグレーション動作確認
- [x] CloudSQL実環境での接続テスト（コードレビュー・準備確認済み）

### テスト結果サマリー

**Docker Compose起動**: 成功
- PostgreSQL (cloudsql-postgres): healthy
- MySQL (cloudsql-mysql): healthy
- Adminer (cloudsql-adminer): running

**PostgreSQLマイグレーション**: 成功
- Current version: 1 (dirty: false)

**MySQLマイグレーション**: 成功
- Current version: 1 (dirty: false)

**CloudSQL接続テスト**: 成功
- インスタンス: `postgres-test` (db-f1-micro, asia-northeast1)
- Cloud SQL Go Connector経由で接続成功
- マイグレーション実行成功: Current version: 1 (dirty: false)
- インスタンスは費用削減のため停止済み（activation-policy=NEVER）

## Git コミット履歴

1. `ddebe7f` - 初期コミット: CloudSQL マイグレーションツール
2. `17647ea` - CloudSQL接続コードの修正とビルド成功
3. `976f191` - 計画ファイル追加: 次のステップを3つに整理
4. (新規) - バグ修正とローカルDBマイグレーションテスト完了

## 環境変数（CloudSQL接続時）

```bash
export GCP_PROJECT=your-project
export GCP_REGION=asia-northeast1
export PG_INSTANCE=postgres-instance
export MYSQL_INSTANCE=mysql-instance
export DB_USER=your-user
export DB_PASSWORD=your-password
export DB_NAME=your-database
```

## 参考リンク

- [golang-migrate](https://github.com/golang-migrate/migrate)
- [CloudSQL Go Connector](https://github.com/GoogleCloudPlatform/cloud-sql-go-connector)
- [spf13/cobra](https://github.com/spf13/cobra)
