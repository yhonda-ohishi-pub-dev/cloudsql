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

# 新しいユーザーを作成する場合
gcloud sql users create USERNAME \
  --instance=INSTANCE_NAME \
  --password=PASSWORD
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
$env:DB_USER = "postgres"
$env:DB_PASSWORD = "your-secure-password"
$env:DB_NAME = "myapp"
```

#### Windows (Command Prompt)
```cmd
set GCP_PROJECT=my-gcp-project
set GCP_REGION=asia-northeast1
set PG_INSTANCE=my-postgres-instance
set MYSQL_INSTANCE=my-mysql-instance
set DB_USER=postgres
set DB_PASSWORD=your-secure-password
set DB_NAME=myapp
```

#### Linux / macOS
```bash
export GCP_PROJECT=my-gcp-project
export GCP_REGION=asia-northeast1
export PG_INSTANCE=my-postgres-instance
export MYSQL_INSTANCE=my-mysql-instance
export DB_USER=postgres
export DB_PASSWORD=your-secure-password
export DB_NAME=myapp
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
# PostgreSQL
./bin/migrate version --db postgres --cloudsql \
  --project $GCP_PROJECT \
  --region $GCP_REGION \
  --instance $PG_INSTANCE \
  --user $DB_USER \
  --password $DB_PASSWORD \
  --database $DB_NAME

# MySQL
./bin/migrate version --db mysql --cloudsql \
  --project $GCP_PROJECT \
  --region $GCP_REGION \
  --instance $MYSQL_INSTANCE \
  --user $DB_USER \
  --password $DB_PASSWORD \
  --database $DB_NAME
```

### トラブルシューティング

| エラー | 原因 | 解決方法 |
|--------|------|----------|
| `could not find default credentials` | ADC未設定 | `gcloud auth application-default login` を実行 |
| `permission denied` | IAM権限不足 | `roles/cloudsql.client` を付与 |
| `Cloud SQL Admin API has not been used` | API未有効 | `gcloud services enable sqladmin.googleapis.com` |
| `connection refused` | ネットワーク設定 | CloudSQLの承認済みネットワークを確認 |

## ライセンス

MIT
