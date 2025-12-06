# 実行済み計画: マルチテナント対応

**実行日**: 2024-12-06
**コミット**: `8b7830d`

---

## 決定事項

- **既存データ**: なし（新規作成）
- **認証方式**: IAM + app_users 紐付け
- **古いusersテーブル**: 削除（init/my_schema両方）→ old/ に移動
- **スキーマ設計**: organization_id + RLS（採用）

---

## 実装内容

### マイグレーションファイル

```
migrations/postgres/
├── 000001_organizations.up/down.sql    # 企業テーブル + current_organization_id()
├── 000002_app_users.up/down.sql        # ユーザー + user_organizations（多対多）
├── 000003_base_tables.up/down.sql      # 全ビジネステーブル（organization_id付き）
├── 000004_enable_rls.up/down.sql       # RLS有効化 + ポリシー
└── old/                                 # 旧スキーマ（v1.0、参照用）
```

### 主要テーブル構造

#### organizations
```sql
CREATE TABLE public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);
```

#### app_users（複数企業対応）
```sql
CREATE TABLE public.app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    iam_email TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    is_superadmin BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE public.user_organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.app_users(id),
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    role TEXT NOT NULL DEFAULT 'member',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, organization_id)
);
```

### RLS実装

```sql
-- ヘルパー関数
CREATE FUNCTION current_organization_id() RETURNS UUID;
CREATE FUNCTION is_superadmin() RETURNS BOOLEAN;

-- 全テーブルにRLS有効化 + ポリシー
-- 条件: organization_id = current_organization_id() OR is_superadmin()
```

---

## 比較検討の記録

### スキーマ分離 vs organization_id + RLS

| 観点 | スキーマ分離 | organization_id + RLS |
|------|-------------|----------------------|
| 分離レベル | 物理的に完全分離 | 論理的分離 |
| セキュリティ | 非常に高い | 高い |
| スケーラビリティ | 企業増でスキーマ増殖 | 単一テーブル |
| マイグレーション | 全スキーマに適用必要 | 1回で完了 |
| 実装コスト | 高 | 中 |
| 運用コスト | 高 | 低 |

**採用理由**:
1. CloudSQL単一インスタンス運用に最適
2. マイグレーション管理がシンプル
3. 企業数増加に対応しやすい
4. IAM認証との統合が容易

---

## README.md 変更履歴セクション

```markdown
## 変更履歴

### v1.0 (旧スキーマ) - migrations/postgres/old/
シングルテナント版。

### v2.0 (現行スキーマ) - migrations/postgres/
マルチテナント対応版（organization_id + RLS）。
```

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

## 完了: CloudSQL本番環境セットアップと認証テスト (2025-12-06)

コミット: `3ddffc5`

### 実装内容

- CloudSQL本番環境へのマイグレーション実行手順をREADMEに追加
- IAMユーザー認証テスト機能を追加
- Cloud SQL Proxy経由での接続確認

### テスト結果

| テスト | 期待結果 | 実際の結果 |
|--------|---------|-----------|
| IAMユーザー + パスワード | ❌ 拒否 | ✅ 拒否 |
| postgres + 正しいパスワード | ✅ 成功 | ✅ 成功 |
| postgres + 間違ったパスワード | ❌ 拒否 | ✅ 拒否 |

---

## 完了: RLS統合テストとMakeターゲット追加 (2025-12-06)

コミット: `0d1df48`

### 実装内容

- `make test-integration`: Docker環境でのRLS統合テスト
- `make test-cloudsql-auth`: CloudSQL認証テスト
- `make proxy-start` / `proxy-stop`: Cloud SQL Proxy管理

---

## 完了: gRPC/proto構成追加 (2025-12-06)

コミット: `6b193f6`

### 作成ファイル

- `proto/migration.proto` - マイグレーションサービス定義
- `buf.yaml` - buf設定
- `buf.gen.yaml` - コード生成設定
- `pkg/pb/.gitkeep` - 生成コード配置先
- `docs/GRPC_IMPLEMENTATION.md` - 実装ガイド

### 更新ファイル

- `Makefile` - proto-gen, proto-lint, proto-format, proto-clean ターゲット追加
- `README.md` - Proto生成手順を拡充
- `.gitignore` - 生成コードを除外

---

## 完了: proto再構築（DBテーブル対応） (2025-12-06)

### 目的
protoとDBスキーマの整合性を保証するため、全DBテーブルに対応するprotoメッセージ型を作成。

### 作成ファイル

- `proto/models.proto` - 全29テーブルに対応するprotoメッセージ定義
  - Core tables: Organization, AppUser, UserOrganization
  - File tables: File, FlickrPhoto
  - Camera files: CamFileExeStage, CamFileExe, CamFile
  - Car inspection: CarInspection, CarInspectionFiles, CarInspectionFilesA/B, CarInspectionDeregistration, etc.
  - Car registry: IchibanCars, DtakoCarsIchibanCars
  - Kudguri (Vehicle Tracking): Kudguri, Kudgcst, Kudgfry, Kudgful, Kudgivt, Kudgsir
  - Sales: Uriage, UriageJisha
  - Dtakologs
- `tests/proto_schema_test.go` - proto-DB整合性テスト

### 更新ファイル

- `Makefile` - `proto-test` コマンド追加
- `buf.yaml` - リントルール調整（PACKAGE_DIRECTORY_MATCH, PACKAGE_VERSION_SUFFIX除外）

### 削除ファイル

- `proto/migration.proto` - DBモデルと関係ないサービス定義のため削除

### テスト結果

```
=== RUN   TestProtoModelsExist
--- PASS: TestProtoModelsExist (0.00s)
=== RUN   TestProtoDBConsistency
--- PASS: TestProtoDBConsistency (0.00s)
=== RUN   TestProtoFieldComments
--- PASS: TestProtoFieldComments (0.00s)
=== RUN   TestProtoPackageNaming
--- PASS: TestProtoPackageNaming (0.00s)
PASS
```

### 使用方法

```bash
# proto整合性テスト
make proto-test

# proto lint
make proto-lint

# protoからGoコード生成
make proto-gen
```
