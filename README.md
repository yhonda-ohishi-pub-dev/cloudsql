# CloudSQL Migration Tool

Go製のCloudSQL（PostgreSQL/MySQL）マイグレーション管理ツール

## 機能

- PostgreSQL / MySQL 両対応
- Google Cloud SQL Connector 統合（IAM認証対応）
- ローカル開発用 Docker Compose 環境
- CLI によるマイグレーション管理
- パスワードレス認証（CloudSQL接続時はIAM認証のみ）

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
--user       # ユーザー名（CloudSQL: IAMユーザーのメールアドレス）
--database   # データベース名
--cloudsql   # CloudSQL接続を使用（IAM認証）
--project    # GCPプロジェクトID
--region     # CloudSQLリージョン
--instance   # CloudSQLインスタンス名
--private-ip # プライベートIPを使用
```

**注意**: このツールはIAM認証のみ対応しています。パスワードオプションは存在しません。

## 環境変数

設定は環境変数でも指定可能（`DB_` プレフィックス）:

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=user@example.com
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
4. 適切な IAM 権限:
   - `roles/cloudsql.client` - Cloud SQL接続
   - `roles/cloudsql.instanceUser` - IAMデータベース認証

## セキュリティ

### IAM認証（パスワードレス）

このツールは**IAM認証のみ**対応しています。パスワードオプションは存在しません。

- パスワード管理が不要
- GCP IAMによる一元的なアクセス制御
- 短期トークンによる自動ローテーション
- Cloud SQL Connector による自動TLS暗号化

### CloudSQL Connectorによるセキュアな接続

CloudSQL Connectorを使用することで、外部からのアクセスはIAM認証に限定されます：

| 接続方法 | 認証 | 結果 |
|---------|------|------|
| Public IP直接接続 | - | ❌ 拒否（authorizedNetworks未設定） |
| CloudSQL Connector経由 | IAM | ✅ 接続成功 |

```
[クライアント] → [Google Cloud API] → [CloudSQL Connector] → [CloudSQL]
                      ↑
                IAM認証がここで行われる
```

- Public IPは有効だが、直接接続は承認済みネットワークがないため不可
- Connectorは**Google Cloud API経由**でセキュアなトンネルを確立
- IAM認証を持つユーザーのみがアクセス可能

### CloudSQLインスタンスの作成

IAM認証を有効にしてインスタンスを作成：

```bash
# PostgreSQL
gcloud sql instances create INSTANCE_NAME \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=asia-northeast1 \
  --database-flags=cloudsql.iam_authentication=on

# MySQL
gcloud sql instances create INSTANCE_NAME \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --region=asia-northeast1 \
  --database-flags=cloudsql_iam_authentication=on
```

### IAMユーザーの作成

```bash
# PostgreSQL（メールアドレス全体を使用）
gcloud sql users create user@example.com \
  --instance=INSTANCE_NAME \
  --type=CLOUD_IAM_USER

# MySQL（@より前の部分のみ使用）
gcloud sql users create user \
  --instance=INSTANCE_NAME \
  --type=CLOUD_IAM_USER
```

### データベース権限の付与

IAMユーザー作成後、Cloud Shell経由でGRANT権限を付与：

```bash
# Cloud Shellに接続
gcloud sql connect INSTANCE_NAME --user=postgres  # PostgreSQL
gcloud sql connect INSTANCE_NAME --user=root      # MySQL
```

```sql
-- PostgreSQL
GRANT ALL ON SCHEMA public TO "user@example.com";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "user@example.com";

-- MySQL
GRANT ALL PRIVILEGES ON database_name.* TO 'user'@'%';
FLUSH PRIVILEGES;
```

## CloudSQL 環境変数の取得方法

### 0. gcloud CLI のインストール

#### Windows
```powershell
# PowerShellで実行（管理者権限推奨）
# インストーラーをダウンロードして実行
Invoke-WebRequest -Uri "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe" -OutFile "$env:TEMP\GoogleCloudSDKInstaller.exe"
Start-Process -FilePath "$env:TEMP\GoogleCloudSDKInstaller.exe" -Wait

# または winget を使用
winget install Google.CloudSDK

# または Chocolatey を使用
choco install gcloudsdk
```

#### macOS
```bash
# Homebrew を使用
brew install --cask google-cloud-sdk

# または公式インストーラー
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

#### Linux (Debian/Ubuntu)
```bash
# APT リポジトリを追加
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# インストール
sudo apt-get update && sudo apt-get install google-cloud-cli
```

#### インストール確認
```bash
gcloud version
```

### 1. GCP認証の設定

```bash
# gcloud CLIのインストール確認
gcloud version

# ログイン（ブラウザが開きます）
gcloud auth login

# Application Default Credentials の設定（必須）
gcloud auth application-default login

# プロジェクトの設定
gcloud config set project YOUR_PROJECT_ID
```

### 2. CloudSQL Admin API の有効化

```bash
gcloud services enable sqladmin.googleapis.com
```

### 3. 環境変数の取得

#### GCP_PROJECT（プロジェクトID）
```bash
# 現在のプロジェクトIDを確認
gcloud config get-value project

# または全プロジェクト一覧から選択
gcloud projects list
```

#### GCP_REGION（リージョン）
```bash
# CloudSQLインスタンスのリージョンを確認
gcloud sql instances list --format="table(name,region)"

# 一般的なリージョン:
# - asia-northeast1 (東京)
# - asia-northeast2 (大阪)
# - us-central1 (アイオワ)
```

#### PG_INSTANCE / MYSQL_INSTANCE（インスタンス名）
```bash
# CloudSQLインスタンス一覧
gcloud sql instances list

# 特定のインスタンスの詳細
gcloud sql instances describe INSTANCE_NAME
```

#### DB_USER（データベースユーザー）
```bash
# インスタンスのユーザー一覧
gcloud sql users list --instance=INSTANCE_NAME

# IAMユーザーを作成する場合（推奨）
# PostgreSQL: メールアドレス全体
gcloud sql users create user@example.com \
  --instance=INSTANCE_NAME \
  --type=CLOUD_IAM_USER

# MySQL: @より前の部分のみ
gcloud sql users create user \
  --instance=INSTANCE_NAME \
  --type=CLOUD_IAM_USER
```

#### DB_NAME（データベース名）
```bash
# インスタンスのデータベース一覧
gcloud sql databases list --instance=INSTANCE_NAME

# 新しいデータベースを作成する場合
gcloud sql databases create DATABASE_NAME \
  --instance=INSTANCE_NAME
```

### 4. 環境変数の設定例

#### Windows (PowerShell)
```powershell
$env:GCP_PROJECT = "my-gcp-project"
$env:GCP_REGION = "asia-northeast1"
$env:PG_INSTANCE = "my-postgres-instance"
$env:MYSQL_INSTANCE = "my-mysql-instance"
# IAM認証の場合（推奨）
$env:DB_USER = "user@example.com"  # PostgreSQL
$env:DB_USER = "user"              # MySQL
$env:DB_NAME = "myapp"
# パスワードは不要（IAM認証）
```

#### Windows (Command Prompt)
```cmd
set GCP_PROJECT=my-gcp-project
set GCP_REGION=asia-northeast1
set PG_INSTANCE=my-postgres-instance
set MYSQL_INSTANCE=my-mysql-instance
set DB_USER=user@example.com
set DB_NAME=myapp
```

#### Linux / macOS
```bash
export GCP_PROJECT=my-gcp-project
export GCP_REGION=asia-northeast1
export PG_INSTANCE=my-postgres-instance
export MYSQL_INSTANCE=my-mysql-instance
# IAM認証の場合（推奨）
export DB_USER=user@example.com  # PostgreSQL
export DB_USER=user              # MySQL
export DB_NAME=myapp
# パスワードは不要（IAM認証）
```

### 5. IAM権限の確認・付与

```bash
# 現在のユーザーのIAM権限を確認
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:YOUR_EMAIL"

# Cloud SQL Client 権限を付与（管理者権限が必要）
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/cloudsql.client"
```

### 6. 接続テスト

```bash
# PostgreSQL（IAM認証）
./bin/migrate version --db postgres --cloudsql \
  --project $GCP_PROJECT \
  --region $GCP_REGION \
  --instance $PG_INSTANCE \
  --user $DB_USER \
  --database $DB_NAME

# MySQL（IAM認証）
./bin/migrate version --db mysql --cloudsql \
  --project $GCP_PROJECT \
  --region $GCP_REGION \
  --instance $MYSQL_INSTANCE \
  --user $DB_USER \
  --database $DB_NAME

# または設定ファイルを使用
./bin/migrate version --db postgres --config configs/config.postgres.dev.yaml
./bin/migrate version --db mysql --config configs/config.mysql.dev.yaml
```

### トラブルシューティング

| エラー | 原因 | 解決方法 |
|--------|------|----------|
| `could not find default credentials` | ADC未設定 | `gcloud auth application-default login` を実行 |
| `permission denied` | IAM権限不足 | `roles/cloudsql.client` と `roles/cloudsql.instanceUser` を付与 |
| `Cloud SQL Admin API has not been used` | API未有効 | `gcloud services enable sqladmin.googleapis.com` |
| `connection refused` | ネットワーク設定 | CloudSQL Connector経由で接続（直接接続は不可） |
| `Access denied for user` | DB権限不足 | Cloud Shell経由でGRANT権限を付与 |

## バックアップと復元

### インスタンスの起動・停止

```bash
# 起動
gcloud sql instances patch INSTANCE_NAME --activation-policy=ALWAYS --project=PROJECT_ID

# 停止
gcloud sql instances patch INSTANCE_NAME --activation-policy=NEVER --project=PROJECT_ID

# 状態確認
gcloud sql instances list --project=PROJECT_ID
```

### バックアップ（スナップショット方式）

インスタンス全体のディスクスナップショットを取得。復元時はインスタンス再起動が必要。

```bash
# バックアップ作成
gcloud sql backups create --instance=INSTANCE_NAME --project=PROJECT_ID

# バックアップ一覧
gcloud sql backups list --instance=INSTANCE_NAME --project=PROJECT_ID

# バックアップから復元（同じインスタンスに上書き）
gcloud sql backups restore BACKUP_ID --restore-instance=INSTANCE_NAME --project=PROJECT_ID

# オペレーション状態確認
gcloud sql operations list --instance=INSTANCE_NAME --project=PROJECT_ID --limit=1
```

### GCSエクスポート・インポート（SQLダンプ方式）

SQLダンプファイルをGCSに保存/読み込み。インスタンス稼働中でも実行可能。

```bash
# GCSバケット作成（初回のみ）
gcloud storage buckets create gs://BUCKET_NAME --location=asia-northeast1 --project=PROJECT_ID

# CloudSQLサービスアカウントにバケットへの書き込み権限を付与
SA_EMAIL=$(gcloud sql instances describe INSTANCE_NAME --project=PROJECT_ID --format="value(serviceAccountEmailAddress)")
gcloud storage buckets add-iam-policy-binding gs://BUCKET_NAME \
  --member=serviceAccount:$SA_EMAIL \
  --role=roles/storage.objectAdmin

# エクスポート（GCSへ）
gcloud sql export sql INSTANCE_NAME gs://BUCKET_NAME/export.sql \
  --database=DATABASE_NAME --project=PROJECT_ID

# インポート（GCSから）
gcloud sql import sql INSTANCE_NAME gs://BUCKET_NAME/export.sql \
  --database=DATABASE_NAME --project=PROJECT_ID

# GCSファイル一覧
gcloud storage ls -l gs://BUCKET_NAME/
```

### バックアップ vs エクスポートの比較

| 項目 | バックアップ | エクスポート (GCS) |
|------|-------------|-------------------|
| 方式 | ディスクスナップショット | SQLダンプ |
| 対象 | インスタンス全体 | 指定したDB/テーブル |
| 復元速度 | 遅い（再起動含む） | 速い |
| 復元時 | インスタンス停止必要 | 稼働中でもOK |
| ストレージ費用 | $0.08/GB/月 | $0.023/GB/月 (GCS Standard) |
| 用途 | 災害復旧、完全復元 | データ移行、長期アーカイブ |

## ライセンス

MIT
